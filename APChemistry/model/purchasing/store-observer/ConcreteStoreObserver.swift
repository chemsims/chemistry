//
// Reactions App
//

import Foundation
import StoreKit

class ConcreteStoreObserver: NSObject, StoreObserver {

    private override init() { }

    static let shared = ConcreteStoreObserver()

    weak var delegate: StoreObserverDelegate?

    var canMakePurchase: Bool {
        SKPaymentQueue.canMakePayments()
    }

    func buy(product: SKProduct) {
        guard canMakePurchase else {
            return
        }
        let payment = SKMutablePayment(product: product)
        paymentQueue.add(payment)
    }

    func restorePurchases() {
        paymentQueue.restoreCompletedTransactions()
    }

    func initialise() {
        paymentQueue.add(self)
    }

    func cleanup() {
        paymentQueue.remove(self)
    }

    private var paymentQueue: SKPaymentQueue {
        SKPaymentQueue.default()
    }
}

extension ConcreteStoreObserver: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            case .deferred: handleDeferred(transaction)
            case .failed: handleFailed(transaction)
            case .purchased: handlePurchased(transaction)
            case .restored: handleRestored(transaction)

            @unknown default:
                print("Unknown transaction state \(transaction.transactionState)")
                break
            }
        }
    }

    private func handleDeferred(_ transaction: SKPaymentTransaction) {
        runOnMain {
            self.delegate?.didDefer(productId: transaction.payment.productIdentifier)
        }
    }

    private func handleRestored(_ transaction: SKPaymentTransaction) {
        print("finished restored")
        paymentQueue.finishTransaction(transaction)
        runOnMain {
            self.delegate?.didRestore(
                productId: transaction.payment.productIdentifier
            )
        }
    }

    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        paymentQueue.finishTransaction(transaction)
        runOnMain {
            self.delegate?.didPurchase(productId: transaction.payment.productIdentifier)
        }
    }

    private func handleFailed(_ transaction: SKPaymentTransaction) {
        paymentQueue.finishTransaction(transaction)
        runOnMain {
            self.delegate?.didFail(productId: transaction.payment.productIdentifier)
        }
    }

    private func runOnMain(_ doRun: @escaping () -> Void) {
        DispatchQueue.main.async {
            doRun()
        }
    }
}
