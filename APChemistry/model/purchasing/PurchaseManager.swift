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

    func prepareStore() {
        self.products.loadProducts()
        self.storeObserver.initialise()
    }

    func cleanup() {
        self.storeObserver.cleanup()
    }

    @Published var units: [UnitWithState]
    @Published var isRestoring = false

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
                units[i].state = .readyForPurchase(product: product)
            } else {
                units[i].state = .failedToLoadProduct
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
        if case let .readyForPurchase(product) = unit.state, let index = index(of: unit.unit) {
            units[index].state = .purchasing
            storeObserver.buy(product: product)
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
            units[index].state = .deferred
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
                units[index].state = .readyForPurchase(product: product)
            } else {
                units[index].state = .failedToLoadProduct
            }
        }
        isRestoring = false
    }

    private func doUnlock(productId: String) {
        if let index = unitIndex(forProduct: productId) {
            units[index].state = .purchased
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


