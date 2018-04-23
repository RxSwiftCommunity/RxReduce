//
//  Action.swift
//  WarpFactorIOS
//
//  Created by Thibault Wittemberg on 18-04-14.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

import Foundation
import RxSwift

public protocol Action: CustomStringConvertible {
    func toStream () -> Observable<Action>
}

public extension Action {
    func toStream () -> Observable<Action> {
        return Observable<Action>.just(self)
    }

    var description: String {
        return "\(type(of: self))"
    }
}
