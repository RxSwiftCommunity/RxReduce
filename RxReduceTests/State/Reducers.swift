//
//  Reducers.swift
//  RxReduceTests
//
//  Created by Thibault Wittemberg on 18-06-11.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

func counterReduce (state: TestState, action: Action) -> CounterState {

    var currentCounter = 0

    // we extract the current counter value from the current state
    switch state.counterState {
    case .decreasing(let counter), .increasing(let counter):
        currentCounter = counter
    default:
        currentCounter = 0
    }

    // according to the action we mutate the counter state
    switch action {
    case let action as IncreaseAction:
        return .increasing(currentCounter+action.increment)
    case let action as DecreaseAction:
        return .decreasing(currentCounter-action.decrement)
    case is ClearAction:
        return .empty
    default:
        return state.counterState
    }
}

func userReduce (state: TestState, action: Action) -> UserState {

    // according to the action we mutate the users state
    switch action {
    case let action as LogUserAction:
        return .loggedIn(name: action.user)
    case is ClearAction:
        return .loggedOut
    default:
        return state.userState
    }
}
