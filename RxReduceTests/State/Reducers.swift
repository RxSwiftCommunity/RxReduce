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

    guard let action = action as? AppAction else { return state.counterState }

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
    case .increase(let increment):
        return .increasing(currentCounter+increment)
    case .decrease(let decrement):
        return .decreasing(currentCounter-decrement)
    case .clear:
        return .empty
    default:
        return state.counterState
    }
}

func userReduce (state: TestState, action: Action) -> UserState {

    guard let action = action as? AppAction else { return state.userState }

    // according to the action we mutate the users state
    switch action {
    case .logUser(let user):
        return .loggedIn(name: user)
    case .clear:
        return .loggedOut
    default:
        return state.userState
    }
}
