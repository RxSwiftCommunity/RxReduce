//
//  Mutator.swift
//  RxReduce
//
//  Created by Thibault Wittemberg on 2018-08-20.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

/// A Mutator holds all the required tools to mutate a State's Substate and
// generate a new State
public struct Mutator<State, SubState> {

    /// The functional Lens used to focus on a subState of a State (both for accessing and mutating)
    let lens: Lens<State, SubState>

    /// The reducer function that allows to mutate a State according to an Action
    let reducer: (State, Action) -> SubState

    public init(lens: Lens<State, SubState>, reducer: @escaping (State, Action) -> SubState) {
        self.lens = lens
        self.reducer = reducer
    }

    /// Mutates a State according to an Action.
    /// It uses the defined lens and reducer to
    /// generate this mutation
    ///
    /// - Parameters:
    ///   - state: the original State to mutate
    ///   - action: the action used to decide the mutation
    /// - Returns: the mutated State
    func apply(state: State, action: Action) -> State {
        return self.lens.set(state, self.reducer(state, action))
    }
}
