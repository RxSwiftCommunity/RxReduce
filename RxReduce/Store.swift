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

    /// Reducer correspond to the apply func of a Mutator
    private typealias Reducer = (State, Action) -> State

    private let stateSubject: BehaviorRelay<State>
    private var neededReducersPerSubState = [String: Int]()
    private var reducers = ContiguousArray<Reducer>()
    private let serialDispatchScheduler: SerialDispatchQueueScheduler = {
        let serialQueue = DispatchQueue(label: "com.rxswiftcommunity.rxreduce.serialqueue")
        return SerialDispatchQueueScheduler.init(queue: serialQueue, internalSerialQueueName: "com.rxswiftcommunity.rxreduce.serialscheduler")
    }()

    /// The global State is exposed via an Observable, just like some kind of "middleware".
    /// This global State will trigger a new value after a dispatch(action) has triggered a "onNext" event.
    public lazy var state: Observable<State> = {
        return self.stateSubject.asObservable()
    }()

    /// Inits a Store with an initial State
    ///
    /// - Parameter state: the initial State
    public init(withState state: State) {

        // Sets the initial State value
        self.stateSubject = BehaviorRelay<State>(value: state)

        // We analyze the State children (aka SubState)
        // to be able to check that each of them will be handled
        // by a reducer function (it allows to be sure that if we
        // add a new SubState to the State, there is a reducer in charge
        // of its mutation)
        let stateMirror = Mirror(reflecting: state)
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
            .map { [unowned self] (action) -> State in
                return self.reducers.reduce(self.stateSubject.value, { (currentState, reducer) -> State in
                    return reducer(currentState, action)
                })
            }
            .do(onNext: { [unowned self] (newState) in
                self.stateSubject.accept(newState)
            })
            .distinctUntilChanged()
            .subscribeOn(self.serialDispatchScheduler)
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
