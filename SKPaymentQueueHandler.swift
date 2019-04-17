//
//  SKPaymentQueueHandler.swift
//  RxStoreKit
//
//  Created by vsccw on 2019/4/17.
//

import RxSwift
import RxCocoa
import StoreKit

public protocol SKPaymentQueueHandler {
    func verifyRequest(transaction: SKPaymentTransaction) -> Observable<SKPaymentTransaction>
}
