//
// Reactions App
//

import Foundation
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
        let unitsToLoad = units.filter { $0.state != .purchased }
        self.products.loadProducts(units: unitsToLoad.map(\.unit))

        unitsToLoad.forEach { unit in
            if let index = index(of: unit.unit) {
                units[index].setState(.loadingProduct)
            }
        }
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
                units[i].setState(.readyForPurchase(product: product))
            } else {
                units[i].setState(.failedToLoadProduct)
            }
        }
    }

    private func index(of unit: Unit) -> Int? {
        units.firstIndex { $0.id == unit.id }
    }
}

// MARK: - Purchase product
extension StoreManager {
    func beginPurchase(of unit: UnitWithState) {
        guard let index = index(of: unit.unit) else {
            return
        }
        switch unit.state {
        case let .readyForPurchase(product):
            units[index].setState(.purchasing)
            storeObserver.buy(product: product)

        case .failedToLoadProduct:
            units[index].setState(.loadingProduct)
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
            units[index].setState(.deferred)
        }
    }

    func didRestore(productId: String) {
        doUnlock(productId: productId)
        isRestoring = false
    }

    func didPurchase(productId: String) {
        doUnlock(productId: productId)
    }

    func didFail(productId: String) {
        if let index = unitIndex(forProduct: productId) {
            let unit = units[index]
            if let product = products.getProduct(forUnit: unit.unit) {
                units[index].setState(.readyForPurchase(product: product))
            } else {
                units[index].setState(.failedToLoadProduct)
            }
        }
        isRestoring = false
    }

    private func doUnlock(productId: String) {
        if let index = unitIndex(forProduct: productId) {
            units[index].setState(.purchased)
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
        if products.isLoading {
            return .loadingProduct
        }
        return .failedToLoadProduct
    }
}


