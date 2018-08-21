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

    private typealias ReducerFunction = (State, Action) -> State

    private var state: State
    private var reducers = [String: ReducerFunction]()

    private var subStateTypes = [String]()
//    private let middlewares: ContiguousArray<Middleware<StateType>>?

    public init(withState state: State) {
        self.state = state

        let stateMirror = Mirror(reflecting: self.state)
        for child in stateMirror.children {
            let childMirror = Mirror(reflecting: child.value)
            subStateTypes.append("\(type(of: childMirror.subjectType))")
        }

//        self.middlewares = middlewares
    }

    public func register<SubState: Equatable> (reducer: Reducer<State, SubState>) throws {
        let key = "\(type(of: SubState.self))"

        if let index = self.subStateTypes.index(of: key) {
            self.subStateTypes.remove(at: index)
        }

        guard self.reducers[key] == nil else {
            throw NSError(domain: "ReducerAlreadyExists", code: -1)
        }
        self.reducers[key] = reducer.apply
    }

    public func dispatch(action: Action) -> Observable<State> {

        guard self.subStateTypes.isEmpty else {
            fatalError("All substate must be handled")
        }

        // every received action is converted to an async action
        return action
            .toAsync()
//            .do(onNext: { [unowned self] (action) in
//                self.middlewares?.forEach({ [unowned self] (middleware) in
//                    middleware(self.state, action)
//                })
//            })
            .map { (action) -> State in

                return self.reducers.values.reduce(self.state, { (currentState, reducer) -> State in
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
