//
//  Reducers.swift
//  RxReduceTests
//
//  Created by Thibault Wittemberg on 18-06-11.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

func counterReducer (state: TestState, action: Action) -> TestState {

    var currentState = state
    var currentCounter = 0

    // we extract the current counter value from the current state
    switch currentState.counterState {
    case .decreasing(let counter), .increasing(let counter):
        currentCounter = counter
    default:
        currentCounter = 0
    }

    // according to the action we mutate the counter state
    switch action {
    case let action as IncreaseAction:
        currentState.counterState = .increasing(currentCounter+action.increment)
        return currentState
    case let action as DecreaseAction:
        currentState.counterState = .decreasing(currentCounter-action.decrement)
        return currentState
    case is ClearCounterAction:
        currentState.counterState = .empty
        return currentState
    default:
        return currentState
    }
}

func usersReducer (state: TestState, action: Action) -> TestState {

    var currentState = state

    // according to the action we mutate the users state
    switch action {
    case let action as AddUserAction:
        currentState.users.append(action.user)
        return currentState
    case is ClearUsersAction:
        currentState.users.removeAll()
        return currentState
    default:
        return currentState
    }
}
