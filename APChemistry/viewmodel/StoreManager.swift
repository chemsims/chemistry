//
// Reactions App
//

import SwiftUI
import StoreKit
import ReactionsCore

class StoreManager: ObservableObject {

    init(
        locker: UnitLocker,
        products: ProductLoader,
        storeObserver: StoreObserver
    ) {
        self.units = Unit.all.map { unit in
            UnitWithState(
                unit: unit,
                state: Self.initialState(
                    for: unit,
                    locker: locker,
                    products: products
                )
            )
        }
        self.locker = locker
        self.products = products
        self.storeObserver = storeObserver

        self.products.delegate = self

        self.storeObserver.delegate = self
    }

    func initialiseStore() {
        self.storeObserver.initialise()
    }

    func cleanupStore() {
        self.storeObserver.cleanup()
    }

    func loadProducts() {
        let unitsToLoad = units.filter(\.shouldLoadProduct)
        unitsToLoad.forEach { unit in
            if let index = index(of: unit.unit) {
                units[index].startLoadingProduct()
            }
        }

        self.products.loadProducts(units: unitsToLoad.map(\.unit))
    }

    @Published var units: [UnitWithState]
    @Published var isRestoring = false

    var canMakePurchase: Bool {
        storeObserver.canMakePurchase
    }

    private var storeObserver: StoreObserver
    private var products: ProductLoader
    private let locker: UnitLocker
}

// MARK: - Load products
extension StoreManager: ProductLoaderDelegate {
    func didLoadProducts(_ products: [SKProduct]) {
        func product(for unit: UnitWithState) -> SKProduct? {
            products.first { $0.productIdentifier == unit.unit.inAppPurchaseID }
        }

        units.indices.forEach { i in
            if let product = product(for: units[i]) {
                units[i].addLoadedProduct(product)
            } else {
                units[i].failedToLoadProduct()
            }
        }
    }

    private func index(of unit: Unit) -> Int? {
        units.firstIndex { $0.id == unit.id }
    }
}

// MARK: - Purchase product
extension StoreManager {
    func beginPurchase(of unit: Unit) {
        guard let index = index(of: unit) else {
            return
        }
        switch units[index].state {
        case let .readyForPurchase(product):
            units[index].startPurchase()
            storeObserver.buy(product: product)

        case .failedToLoadProduct:
            units[index].startLoadingProduct()
            let unit = units[index].unit
            products.loadProducts(units: [unit])
            
        default: break
        }
    }

    func restorePurchases() {
        guard !isRestoring else {
            return
        }
        isRestoring = true
        storeObserver.restorePurchases()
    }
}

// MARK: - Purchase delegate
extension StoreManager: StoreObserverDelegate {

    func didDefer(productId: String) {
        if let index = unitIndex(forProduct: productId) {
            units[index].deferPurchase()
        }
    }

    func didRestore(productId: String) {
        doUnlock(productId: productId, isRestoring: true)
    }

    func restoreComplete() {
        isRestoring = false
        NotificationViewModel.showRestoredNotification()
    }

    func didPurchase(productId: String) {
        doUnlock(productId: productId, isRestoring: false)
        NotificationViewModel.showSuccessfulPurchaseNotification()
    }

    func didFail(productId: String) {
        if let index = unitIndex(forProduct: productId) {
            let unit = units[index]
            let product = products.getProduct(forUnit: unit.unit)
            units[index].failedToPurchase(product: product)
        }
        isRestoring = false
        NotificationViewModel.showFailedPurchaseNotification()
    }

    private func doUnlock(
        productId: String,
        isRestoring: Bool
    ) {
        if let index = unitIndex(forProduct: productId) {
            withAnimation {
                if isRestoring {
                    units[index].restored()
                } else {
                    units[index].purchased()
                }

            }
            locker.unlock(units[index].unit)
        }
    }

    private func unitIndex(forProduct productId: String) -> Int? {
        units.firstIndex { $0.unit.inAppPurchaseID == productId }
    }
}

extension StoreManager {
    static func initialState(
        for unit: Unit,
        locker: UnitLocker,
        products: ProductLoader
    ) -> PurchaseState {
        if locker.isUnlocked(unit) {
            return .purchased
        }
        if let product = products.getProduct(forUnit: unit) {
            return .readyForPurchase(product: product)
        }
        return .waitingToLoadProduct
    }
}
