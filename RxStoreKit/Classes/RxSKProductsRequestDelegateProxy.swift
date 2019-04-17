//
//  SKProductsRequestDelegateProxy.swift
//  RxStoreKit
//
//  Created by vsccw on 2019/4/16.
//

import StoreKit
import RxSwift
import RxCocoa

public class RxSKProductsRequestDelegateProxy:
        DelegateProxy<SKProductsRequest, SKProductsRequestDelegate>,
        DelegateProxyType,
        SKProductsRequestDelegate {
    
    public let productsResponse = PublishSubject<SKProductsResponse>()
    
    public init(parentObject: ParentObject) {
        super.init(parentObject: parentObject, delegateProxy: RxSKProductsRequestDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxSKProductsRequestDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: SKProductsRequest) -> SKProductsRequestDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: SKProductsRequestDelegate?, to object: SKProductsRequest) {
        object.delegate = delegate
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        (_forwardToDelegate as? SKProductsRequestDelegate)?.productsRequest(request, didReceive: response)
        productsResponse.onNext(response)
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        (_forwardToDelegate as? SKProductsRequestDelegate)?.request?(request, didFailWithError: error)
        productsResponse.onError(error)
    }
    
    deinit {
        productsResponse.onCompleted()
        productsResponse.dispose()
    }
    
}
