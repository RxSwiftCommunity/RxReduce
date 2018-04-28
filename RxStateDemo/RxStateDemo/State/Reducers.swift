//
//  Reducers.swift
//  RxStateDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxState

func reducer (state: DemoState?, action: Action) -> DemoState {

    let newState = state ?? DemoState(counter: 0)

    switch action {
    case let action as IncreaseAction:
        return DemoState(counter: newState.counter+action.increment)
    case let action as DecreaseAction:
        return DemoState(counter: newState.counter-action.decrement)
    default:
        return newState
    }
}
