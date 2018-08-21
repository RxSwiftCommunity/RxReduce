//
//  State.swift
//  RxReduceTests
//
//  Created by Thibault Wittemberg on 18-06-11.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

struct TestState: Equatable {
    var counterState: CounterState
    var userState: UserState
}

enum CounterState: Equatable {
    case empty
    case increasing (Int)
    case decreasing (Int)
}

enum UserState: Equatable {
    case loggedIn (name: String)
    case loggedOut
}
