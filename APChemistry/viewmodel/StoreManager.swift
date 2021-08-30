//
// Reactions App
//

import SwiftUI
import StoreKit
import ReactionsCore

class StoreManager: ObservableObject {

    init(
        locker: ProductLocker,
        productLoader: ProductLoader,
        storeObserver: StoreObserver
    ) {
        self.products = InAppPurchase.allCases.map { unit in
            InAppPurchaseWithState(
                type: unit,
                state: Self.initialState(
                    for: unit,
                    locker: locker,
                    productLoader: productLoader
                )
            )
        }
        self.locker = locker
        self.productLoader = productLoader
        self.storeObserver = storeObserver

        self.productLoader.delegate = self
        self.storeObserver.delegate = self
    }

    func initialiseStore() {
        self.storeObserver.initialise()
    }

    func cleanupStore() {
        self.storeObserver.cleanup()
    }

    func loadProducts() {
        let productsToLoad = products.filter(\.shouldLoadProduct)
        productsToLoad.forEach { unit in
            if let index = index(of: unit.type) {
                products[index].startLoadingProduct()
            }
        }

        self.productLoader.loadSKProducts(types: productsToLoad.map(\.type))
    }

    func price(forProduct product: InAppPurchase) -> String? {
        productState(for: product)?.skProduct?.formattedPrice
    }

    func productState(for type: InAppPurchase) -> InAppPurchaseWithState? {
        products.first { $0.type.inAppPurchaseId == type.inAppPurchaseId }
    }

    @Published var products: [InAppPurchaseWithState]
    @Published var isRestoring = false

    var canMakePurchase: Bool {
        storeObserver.canMakePurchase
    }

    private var storeObserver: StoreObserver
    private var productLoader: ProductLoader
    let locker: ProductLocker
}

// MARK: - Load products
extension StoreManager: ProductLoaderDelegate {
    func didLoadProducts(_ skProducts: [SKProduct]) {
        func skProduct(for unit: InAppPurchaseWithState) -> SKProduct? {
            skProducts.first { $0.productIdentifier == unit.type.inAppPurchaseId }
        }

        products.indices.forEach { i in
            if let product = skProduct(for: products[i]) {
                products[i].addLoadedProduct(product)
            } else {
                products[i].failedToLoadProduct()
            }
        }
    }

    private func index(of unit: InAppPurchase) -> Int? {
        products.firstIndex { $0.type.inAppPurchaseId == unit.inAppPurchaseId }
    }
}

// MARK: - Purchase product
extension StoreManager {
    func beginPurchase(of unit: InAppPurchase) {
        guard let index = index(of: unit) else {
            return
        }
        switch products[index].state {
        case let .readyForPurchase(product):
            products[index].startPurchase()
            storeObserver.buy(product: product)

        case .failedToLoadProduct:
            products[index].startLoadingProduct()
            let unit = products[index].type
            productLoader.loadSKProducts(types: [unit])
            
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
            products[index].deferPurchase()
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
        
        if let index = unitIndex(forProduct: productId),
           products[index].type.isConsumableTip {
            NotificationViewModel.showExtraTipNotification()
        } else {
            NotificationViewModel.showSuccessfulPurchaseNotification()
        }
    }

    func didFail(productId: String) {
        if let index = unitIndex(forProduct: productId) {
            let productType = products[index].type
            let skProduct = productLoader.getSKProduct(for: productType)
            products[index].failedToPurchase(product: skProduct)
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
                    products[index].restored()
                } else {
                    products[index].purchased()
                }
            }
            locker.unlock(products[index].type)
        }
    }

    private func unitIndex(forProduct productId: String) -> Int? {
        products.firstIndex { $0.type.inAppPurchaseId == productId }
    }
}

extension StoreManager {
    static func initialState(
        for unit: InAppPurchase,
        locker: ProductLocker,
        productLoader: ProductLoader
    ) -> PurchaseState {
        if locker.isUnlocked(unit) {
            return .purchased
        }
        if let product = productLoader.getSKProduct(for: unit) {
            return .readyForPurchase(product: product)
        }
        return .waitingToLoadProduct
    }
}

extension StoreManager {
    static let preview = StoreManager(
        locker: InMemoryProductLocker(),
        productLoader: DebugProductLoader(),
        storeObserver: DebugStoreObserver()
    )
}
