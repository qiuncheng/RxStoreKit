import StoreKit
import RxSwift
import RxCocoa

public class RxSKPaymentTransactionObserver {
    fileprivate let observer: Observer
    
    public static let shared = RxSKPaymentTransactionObserver()
    
    public init() {
        observer = Observer()
        SKPaymentQueue.default().add(observer)
    }
    
    deinit {
        SKPaymentQueue.default().remove(observer)
    }
}

extension RxSKPaymentTransactionObserver: ReactiveCompatible { }

extension Reactive where Base: RxSKPaymentTransactionObserver {
   
    public var updatedTransactions: Observable<[SKPaymentTransaction]> {
        return base.observer.updatedTransactions.asObservable()
    }
    
    public var restoreCompletedTransactions: Observable<Void> {
        return base.observer.restoreCompletedTransactions.asObservable()
    }
    
    public var updatedDownloads: Observable<[SKDownload]> {
        return base.observer.updatedDownloads.asObservable()
    }
    
    public var removedTransactions: Observable<[SKPaymentTransaction]> {
        return base.observer.removedTransactions.asObservable()
    }
    
    public var restoreCompletedTransactionsFailedWithError: Observable<Error> {
        return base.observer.restoreCompletedTransactionsFailedWithError.asObservable()
    }
}

fileprivate class Observer: NSObject, SKPaymentTransactionObserver {
    
    let updatedTransactions = PublishSubject<[SKPaymentTransaction]>()
    let restoreCompletedTransactions = PublishSubject<Void>()
    let updatedDownloads = PublishSubject<[SKDownload]>()
    let removedTransactions = PublishSubject<[SKPaymentTransaction]>()
    let restoreCompletedTransactionsFailedWithError = PublishSubject<Error>()
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        updatedTransactions.onNext(transactions)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        restoreCompletedTransactions.onNext(())
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        updatedDownloads.onNext(downloads)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        removedTransactions.onNext(transactions)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreCompletedTransactionsFailedWithError.onNext(error)
    }
    
}
