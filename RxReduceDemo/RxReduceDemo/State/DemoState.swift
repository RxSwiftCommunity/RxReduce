//
//  DemoState.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

struct DemoState: State, Equatable {
    var counterState: CounterState
    var usersState: [String]
}

enum CounterState: Equatable {
    case empty
    case increasing (counter: Int)
    case decreasing (counter: Int)
    case stopped
}
