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

extension Array: Action where Element == Action {
    public func toStream() -> Observable<Action> {
        return Observable<Action>.concat(self.map { $0.toStream() })
    }
}
