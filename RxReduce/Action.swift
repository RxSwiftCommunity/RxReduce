//
//  Action.swift
//  RxReduce
//
//  Created by Thibault Wittemberg on 18-04-14.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift

/// Conform to an Action to mutate the State synchronously or asynchronously
/// Arrays of Actions and Observable of Action are considered to be Actions as well
public protocol Action {

    /// Convert the action into an Observable so it is compliant with asynchronous processing
    ///
    /// - Returns: the asynchronous action
    func toAsync () -> Observable<Action>
}

// MARK: - Default implementation of toAsync (just transform Self in an Observable)
extension Action {
    public func toAsync () -> Observable<Action> {
        return Observable<Action>.just(self)
    }
}

// MARK: - Default implementation of toAsync: Array<Action> is also an Action
extension Array: Action where Element == Action {
    public func toAsync () -> Observable<Action> {
        return Observable<Action>.concat(self.map { $0.toAsync() })
    }
}

// MARK: - Default implementation of toAsync: Observable<Action> is also an Action
extension Observable: Action where Element == Action {
    public func toAsync () -> Observable<Action> {
        return self
    }
}
