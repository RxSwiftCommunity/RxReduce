//
//  Action.swift
//  WarpFactorIOS
//
//  Created by Thibault Wittemberg on 18-04-14.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

import Foundation
import RxSwift

/// Conform to an Action to mutate the State synchronously or asynchronously
public protocol Action {
    func toAsync () -> Observable<Action>
}

extension Action {
    public func toAsync () -> Observable<Action> {
        return Observable<Action>.just(self)
    }
}

extension Array: Action where Element == Action {
    public func toAsync () -> Observable<Action> {
        return Observable<Action>.concat(self.map { $0.toAsync() })
    }
}

extension Observable: Action where Element == Action {
    public func toAsync () -> Observable<Action> {
        return self
    }
}
