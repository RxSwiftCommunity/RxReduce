//
//  Lens.swift
//  RxReduce
//
//  Created by Thibault Wittemberg on 2018-08-20.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

/// A Lens is a generic way to access and mutate a value type
public struct Lens<State, SubState> {

    /// retrieves a Substate from a State
    let get: (State) -> SubState

    /// Generates a new State based on an original State and on an original SubState 
    let set: (State, SubState) -> State
}
