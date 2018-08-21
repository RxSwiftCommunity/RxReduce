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

///// A Reducer mutates an input state into an output state according to an action
//public typealias Reducer<StateType: Equatable> = (_ state: StateType, _ action: Action) -> StateType
//
///// A Middleware has not effect on the state, it us just triggered by a dispatch action
//public typealias Middleware<StateType: Equatable> = (_ state: StateType, _ action: Action) -> Void

/// A Store holds the state, mutate the state through actions / reducers and exposes the state via a Driver
/// A Store is dedicated to a State Type
public final class Store<State: Equatable> {

    public typealias ReducerFunction = (State, Action) -> State

    private var state: State
    private var reducers = [ReducerFunction]()
//    private let reducers: ContiguousArray<Reducer<StateType>>
//    private let middlewares: ContiguousArray<Middleware<StateType>>?

    public init(withState state: State) {
        self.state = state
//        self.middlewares = middlewares
    }

    public func register<SubState: Equatable> (reducer: Reducer<State, SubState>) {
        self.reducers.append(reducer.apply)
    }

    public func dispatch(action: Action) -> Observable<State> {
        // every received action is converted to an async action
        return action
            .toAsync()
//            .do(onNext: { [unowned self] (action) in
//                self.middlewares?.forEach({ [unowned self] (middleware) in
//                    middleware(self.state, action)
//                })
//            })
            .map { (action) -> State in

                return self.reducers.reduce(self.state, { (currentState, reducer) -> State in
                    return reducer(currentState, action)
                })
            }.do(onNext: { [unowned self] (newState) in
                self.state = newState
            }).distinctUntilChanged()
    }

//    public func dispatch<SubStateType: Equatable>(action: Action, on: @escaping (State) -> SubStateType) -> Observable<SubStateType> {
//        return self.dispatch(action: action).map { on($0) }
//    }

}
