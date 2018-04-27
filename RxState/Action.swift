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
/// For async processing, just override the `toAsync` function
public protocol Action {
    func toAsync<StateType: State> (withState state: StateType?) -> Observable<Action>
}

public extension Action {
    func toAsync<StateType: State> (withState state: StateType? = nil) -> Observable<Action> {
        return Observable<Action>.just(self)
    }
}

extension Array: Action where Element == Action {
    public func toAsync<StateType: State> (withState state: StateType? = nil) -> Observable<Action> {
        return Observable<Action>.concat(self.map { $0.toAsync(withState: state) })
    }
}

extension Observable: Action where Element == Action {
    public func toAsync<StateType: State> (withState state: StateType? = nil) -> Observable<Action> {
        return self
    }
}
