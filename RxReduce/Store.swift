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

/// A Store holds the state, mutate the state through Actions and Mutators
/// Internally, each Mutator defines a Reducer function that is applied sequentially
/// to the internal State.
public final class Store<State: Equatable> {

    /// A Middleware acts like a valve in which a dispatched Action passes through.
    /// It cannot mutate the State. Middlewares can be used for logging purposes for instance
    public typealias Middleware = (_ state: State, _ action: Action) -> Void

    private typealias ReducerFunction = (State, Action) -> State

    private var state: State
    private var reducers = [String: ReducerFunction]()

    private var subStateTypes = [String]()
    private var middlewares = ContiguousArray<Middleware>()

    /// Inits a Store with an initial State
    ///
    /// - Parameter state: the initial State
    public init(withState state: State) {
        self.state = state

        // We analyze the State children (aka SubState)
        // to be able to check that each of them will be handled
        // by a reducer function (it allows to be sure that if we
        // add a new SubState to the State, there is a reducer in charge
        // of its mutation)
        let stateMirror = Mirror(reflecting: self.state)
        stateMirror.children.forEach {
            let childMirror = Mirror(reflecting: $0.value)
            self.subStateTypes.append("\(type(of: childMirror.subjectType))")
        }
    }

    /// Registers a Mutator dedicated to a State and a SubState mutation.
    /// The Mutator internally references a reducer that will be applied to the
    /// current State according to an Action. This will produce a new State.
    /// Store does not keep a reference on the Mutator, only on the reducer it defines.
    /// Each Mutator is applied in sequence when a new Action is dispatched.
    /// There MUST be a Mutator for every State's SubState
    /// There MUST be only one Mutator per SubState
    ///
    /// - Parameter mutator: The Mutator dedicated to a State/Substate mutation
    /// - Throws: StoreError.reducerAlreadyExist if a Mutator has already been registered for this SubState
    public func register<SubState: Equatable> (mutator: Mutator<State, SubState>) throws {
        let key = "\(type(of: SubState.self))"

        if let index = self.subStateTypes.index(of: key) {
            self.subStateTypes.remove(at: index)
        }

        guard self.reducers[key] == nil else {
            throw StoreError.mutatorAlreadyExist
        }

        self.reducers[key] = mutator.apply
    }

    /// Registers a Middleware. Middlewares will be applied in sequence
    /// in the same order than their addition
    ///
    /// - Parameter middleware: The Middleware to add
    public func register (middleware: @escaping Middleware) {
        self.middlewares.append(middleware)
    }

    /// Dispatches an Action to the registered Mutators.
    /// The Action will first go through the Middlewares and
    /// then through the Reducers defined in the registered Mutators
    /// producing a mutated State.
    ///
    /// - Parameter action: The Action that will be handled by the reducers
    /// - Returns: The mutated State
    public func dispatch(action: Action) -> Observable<State> {

        guard self.subStateTypes.isEmpty else {
            fatalError("All substate must be handled")
        }

        // every received action is converted to an async action
        return action
            .toAsync()
            .do(onNext: { [unowned self] (action) in
                self.middlewares.forEach({ [unowned self] (middleware) in
                    middleware(self.state, action)
                })
            })
            .map { (action) -> State in
                return self.reducers.values.reduce(self.state, { (currentState, reducer) -> State in
                    return reducer(currentState, action)
                })
            }.do(onNext: { [unowned self] (newState) in
                self.state = newState
            }).distinctUntilChanged()
    }

    /// Dispatches an Action to the registered Mutators but instead of
    /// returning the mutated State, it allows to focus on a sub set of the State.
    ///
    /// - Parameters:
    ///   - action: The Action that will be handled by the reducers
    ///   - on: The closure that defines the sub set of the State that we want to observe
    /// - Returns: The mutated sub set of the State
    public func dispatch<SubStateType: Equatable>(action: Action, on: @escaping (State) -> SubStateType) -> Observable<SubStateType> {
        return self.dispatch(action: action).map { on($0) }.distinctUntilChanged()
    }

}
