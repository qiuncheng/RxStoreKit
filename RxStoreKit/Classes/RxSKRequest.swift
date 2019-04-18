//
//  RxSKProducts.swift
//  TongZhuo
//
//  Created by vsccw on 2019/4/18.
//  Copyright © 2019 tongzhuogame.com. All rights reserved.
//

import StoreKit
import RxSwift
import RxCocoa

public struct RxSKRequest {
    
    public static func start(productID: String) -> Observable<SKPaymentTransaction> {
        let products = Set(arrayLiteral: productID)
        let request = SKProductsRequest(productIdentifiers: products)
        return request.rx.start()
    }
}
