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
                .subscribe(onNext: { (products) in
                    if products.isEmpty {
                        observer.onError(RxSKError.productNotFound)
                        return
                    }
                    products.forEach({
                        let payment = SKPayment(product: $0)
                        SKPaymentQueue.default().add(payment)
                    })
                })
                
            let disposable1 = SKPaymentQueue.observer.rx.updatedTransactions
                .subscribe(onNext: { (transactions) in
                    var needComplete = false
                    for transaction in transactions {
                        switch transaction.transactionState {
                        case .purchased:
                            observer.onNext(transaction)
                            needComplete = true
                        case .failed:
                            if let error = transaction.error {
                                observer.onError(error)
                            } else {
                                observer.onNext(transaction)
                            }
                            needComplete = true
                        case .restored:
                            observer.onNext(transaction)
                            needComplete = true
                        default:
                            break
                        }
                    }
                    if needComplete {
                        observer.onCompleted()
                    }
                }, onError: { (error) in
                    observer.onError(error)
                })
            
            self.base.start()
            
            return Disposables.create {
                disposable.dispose()
                disposable1.dispose()
            }
        })
    }
}
