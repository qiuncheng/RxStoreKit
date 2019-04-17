//
//  SKProductsRequest+Rx.swift
//  RxStoreKit
//
//  Created by vsccw on 2019/4/16.
//

import StoreKit
import RxSwift
import RxCocoa

public extension Reactive where Base: SKProductsRequest {
    
    var observer: RxSKPaymentTransactionObserver {
        return RxSKPaymentTransactionObserver.shared
    }
    
    var delegate: DelegateProxy<SKProductsRequest, SKProductsRequestDelegate> {
        return RxSKProductsRequestDelegateProxy.proxy(for: base)
    }
    
    var productsResponse: Observable<SKProductsResponse> {
        return RxSKProductsRequestDelegateProxy.proxy(for: base)
            .productsResponse
            .asObservable()
    }
    
    func start<H>(_ handler: H) -> Observable<SKPaymentTransaction> where H: SKPaymentQueueHandler {
        return Observable.create({ [weak base = self.base] (observer) -> Disposable in
            guard let aBase = base else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let disposable = aBase.rx.productsResponse
                .flatMap({ (response) -> Observable<SKProduct> in
                    return Observable.from(response.products)
                })
                .map({ (product) -> SKPayment in
                    return SKPayment(product: product)
                })
                .do(onNext: { (payment) in
                    SKPaymentQueue.default().add(payment)
                })
                .withLatestFrom(aBase.rx.observer.rx.updatedTransactions)
                .flatMapLatest({ (transaction) -> Observable<SKPaymentTransaction> in
                    switch transaction.transactionState {
                    case .purchased:
                        return handler.verifyRequest(transaction: transaction)
                    default:
                        return Observable.of(transaction)
                    }
                })
                .subscribe(observer)
            
            return Disposables.create {
                disposable.dispose()
            }
        })
    }
}
