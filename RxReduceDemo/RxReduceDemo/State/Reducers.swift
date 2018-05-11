//
//  Reducers.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

func demoReducer (state: DemoState?, action: Action) -> DemoState {

    let currentState = state ?? DemoState.empty

    var currentCounter = 0

    // we extract the current counter value from the current state
    switch currentState {
    case .decreasing(let counter), .increasing(let counter):
        currentCounter = counter
    default:
        currentCounter = 0
    }

    // according to the action we create a new state
    switch action {
    case let action as IncreaseAction:
        return .increasing(counter: currentCounter+action.increment)
    case let action as DecreaseAction:
        return .decreasing(counter: currentCounter-action.decrement)
    default:
        return currentState
    }
}
