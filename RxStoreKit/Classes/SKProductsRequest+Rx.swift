//
//  SKProductsRequest+Rx.swift
//  RxStoreKit
//
//  Created by vsccw on 2019/4/16.
//

import StoreKit
import RxSwift
import RxCocoa

public extension SKPaymentQueue {
    static var observer: RxSKPaymentTransactionObserver {
        return RxSKPaymentTransactionObserver.shared
    }
}

public extension Reactive where Base: SKProductsRequest {
    
    var delegate: DelegateProxy<SKProductsRequest, SKProductsRequestDelegate> {
        return RxSKProductsRequestDelegateProxy.proxy(for: base)
    }
    
    var productsResponse: Observable<SKProductsResponse> {
        return RxSKProductsRequestDelegateProxy.proxy(for: base)
            .productsResponse
            .asObservable()
    }
    
    func start() -> Observable<SKPaymentTransaction> {
        return Observable.create({ (observer) -> Disposable in
            let disposable = self.base.rx.productsResponse
                .map({ $0.products })
                .flatMapLatest({ (products) -> Observable<[SKPaymentTransaction]> in
                    guard !products.isEmpty else {
                        observer.onError(RxSKError.productNotFound)
                        return Observable.empty()
                    }
                    products.forEach({
                        let payment = SKPayment(product: $0)
                        SKPaymentQueue.default().add(payment)
                    })
                    return SKPaymentQueue.observer.rx.updatedTransactions
                })
                .subscribe(onNext: { (transactions) in
                    for transaction in transactions {
                        switch transaction.transactionState {
                        case .purchased:
                            SKPaymentQueue.default().finishTransaction(transaction)
                            observer.onNext(transaction)
                        case .failed:
                            SKPaymentQueue.default().finishTransaction(transaction)
                            if let error = transaction.error {
                                observer.onError(error)
                            } else {
                                observer.onNext(transaction)
                            }
                        case .restored:
                            SKPaymentQueue.default().finishTransaction(transaction)
                            observer.onNext(transaction)
                        default:
                            break
                        }
                    }
                    observer.onCompleted()
                }, onError: { (error) in
                    observer.onError(error)
                })
            self.base.start()
            
            return Disposables.create {
                disposable.dispose()
            }
        })
    }
}
