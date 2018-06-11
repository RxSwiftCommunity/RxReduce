//
//  State.swift
//  RxReduceTests
//
//  Created by Thibault Wittemberg on 18-06-11.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

struct TestState: State {
    var counterState: CounterState
    var users: [String]
}

enum CounterState: Equatable {
    case empty
    case increasing (Int)
    case decreasing (Int)
}
