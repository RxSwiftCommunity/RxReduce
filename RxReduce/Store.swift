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

/// A Store holds the state, mutate the state through Actions and Reducers.
/// Internally, Reducers come from registered Mutator defines a Reducer.
public final class Store<State: Equatable> {

    /// A Middleware acts like a valve in which a dispatched Action passes through.
    /// It cannot mutate the State. Middlewares can be used for logging purposes for instance
    public typealias Middleware = (_ state: State, _ action: Action) -> Void
    private typealias Reducer = (State, Action) -> State

    private var state: State
    private var neededReducersPerSubState = [String: Int]()
    private var reducers = ContiguousArray<Reducer>()
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
        stateMirror
            .children
            .map { Mirror(reflecting: $0.value) }
            .map { "\(type(of: $0.subjectType))" }
            .forEach { [unowned self] (subStateType) in
                if let neededReducerForSubState = self.neededReducersPerSubState[subStateType] {
                    self.neededReducersPerSubState[subStateType] = neededReducerForSubState + 1
                } else {
                    self.neededReducersPerSubState[subStateType] = 1
                }
        }

        self.reducers.reserveCapacity(self.neededReducersPerSubState.count)
    }

    /// Registers a Mutator dedicated to a State/SubState mutation.
    /// The Mutator internally references a reducer that will be later applied to the
    /// current State according to an Action. This will produce a new State.
    /// Store does not keep a reference on the Mutator, only on the Reducer it defines.
    /// Each Reducer is applied in sequence when a new Action is dispatched.
    /// There MUST be a Reducer for every State's SubState
    /// There MUST be only one Reducer per SubState
    ///
    /// - Parameter mutator: The Mutator dedicated to a State/Substate mutation
    public func register<SubState: Equatable> (mutator: Mutator<State, SubState>) {
        let subStateType = "\(type(of: SubState.self))"

        guard let neededReducerForSubState = self.neededReducersPerSubState[subStateType] else {
            fatalError("Mutator \(mutator) is not relevant for this State")
        }

        guard neededReducerForSubState > 0 else {
            fatalError("No more Mutator cannot be registered for SubState \(subStateType)")
        }

        self.reducers.append(mutator.apply)
        self.neededReducersPerSubState[subStateType] = neededReducerForSubState - 1
    }

    /// Registers a Middleware. Middlewares will be applied in sequence
    /// in the same order than their addition
    ///
    /// - Parameter middleware: The Middleware to add
    public func register (middleware: @escaping Middleware) {
        self.middlewares.append(middleware)
    }

    /// Dispatches an Action to the registered Reducers.
    /// The Action will first go through the Middlewares and
    /// then through the Reducers producing a mutated State.
    ///
    /// - Parameter action: The Action that will be handled by the reducers
    /// - Returns: The mutated State
    public func dispatch(action: Action) -> Observable<State> {

        let subStatesNotReduced = !self.neededReducersPerSubState.filter { $0.value > 0 }.isEmpty

        guard !subStatesNotReduced else {
            fatalError("All substate must be reduced")
        }

        // every received action is converted to an async action
        return action
            .toAsync()
            .do(onNext: { [unowned self] (action) in
                self.middlewares.forEach({ [unowned self] (middleware) in
                    middleware(self.state, action)
                })
            })
            .map { [unowned self] (action) -> State in
                return self.reducers.reduce(self.state, { (currentState, reducer) -> State in
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
    ///   - focusingOn: The closure that defines the sub set of the State that we want to observe
    /// - Returns: The mutated sub set of the State
    public func dispatch<StateContent: Equatable>(action: Action, focusingOn: @escaping (State) -> StateContent) -> Observable<StateContent> {
        return self.dispatch(action: action).map { focusingOn($0) }.distinctUntilChanged()
    }

}
