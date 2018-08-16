//
//  Store.swift
//  RxReduce
//
//  Created by Thibault Wittemberg on 18-04-15.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// A Reducer mutates an input state into an output state according to an action
public typealias Reducer<StateType: Equatable> = (_ state: StateType, _ action: Action) -> StateType

/// A Middleware has not effect on the state, it us just triggered by a dispatch action
public typealias Middleware<StateType: Equatable> = (_ state: StateType, _ action: Action) -> Void

/// A Store holds the state, mutate the state through actions / reducers and exposes the state via a Driver
/// A Store is dedicated to a State Type
public final class Store<StateType: Equatable> {

    private var state: StateType
    private let reducers: ContiguousArray<Reducer<StateType>>
    private let middlewares: ContiguousArray<Middleware<StateType>>?

    public init(withState state: StateType,
                withReducers reducers: ContiguousArray<Reducer<StateType>>,
                withMiddlewares middlewares: ContiguousArray<Middleware<StateType>>? = nil) {
        self.state = state
        self.reducers = reducers
        self.middlewares = middlewares
    }

    public func dispatch(action: Action) -> Observable<StateType> {
        // every received action is converted to an async action
        return action
            .toAsync()
            .do(onNext: { [unowned self] (action) in
                self.middlewares?.forEach({ [unowned self] (middleware) in
                    middleware(self.state, action)
                })
            })
            .map { (action) -> StateType in

                return self.reducers.reduce(self.state, { (previousState, reducer) -> StateType in
                    return reducer(previousState, action)
                })
            }.do(onNext: { [unowned self] (newState) in
                self.state = newState
            }).distinctUntilChanged()
    }

    public func dispatch<SubStateType: Equatable>(action: Action, on: @escaping (StateType) -> SubStateType) -> Observable<SubStateType> {
        return self.dispatch(action: action).map { on($0) }
    }

}
