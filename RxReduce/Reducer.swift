//
//  Reducer.swift
//  RxReduce
//
//  Created by Thibault Wittemberg on 2018-08-20.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

import Foundation

public struct Reducer<State: Equatable, SubState: Equatable> {
    let lens: Lens<State, SubState>
    let reducer: (State, Action) -> SubState

    func apply(state: State, action: Action) -> State {
        return self.lens.set(state, self.reducer(state, action))
    }
}
