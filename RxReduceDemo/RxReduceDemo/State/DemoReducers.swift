//
//  Reducers.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

func counterReducer (state: DemoState?, action: Action) -> DemoState {

    var currentState = state ?? DemoState(counterState: CounterState.empty, usersState: [])

    var currentCounter = 0

    // we extract the current counter value from the current state
    switch currentState.counterState {
    case .decreasing(let counter), .increasing(let counter):
        currentCounter = counter
    default:
        currentCounter = 0
    }

    // according to the action we create a new state
    switch action {
    case let action as IncreaseAction:
        currentState.counterState = .increasing(counter: currentCounter+action.increment)
        return currentState
    case let action as DecreaseAction:
        currentState.counterState = .decreasing(counter: currentCounter-action.decrement)
        return currentState
    default:
        return currentState
    }
}

func usersReducer (state: DemoState?, action: Action) -> DemoState {

    var currentState = state ?? DemoState(counterState: CounterState.empty, usersState: [])

    // according to the action we create a new state
    switch action {
    case let action as AddUserAction:
        currentState.usersState.append(action.user)
        return currentState
    default:
        return currentState
    }
}
