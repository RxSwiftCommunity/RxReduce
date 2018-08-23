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
    let lens: Lens<State, SubState>
    let reducer: (State, Action) -> SubState

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
