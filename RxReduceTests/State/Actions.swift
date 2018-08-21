//
//  Actions.swift
//  RxReduceTests
//
//  Created by Thibault Wittemberg on 18-06-11.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

struct IncreaseAction: Action {
    let increment: Int
}

struct DecreaseAction: Action {
    let decrement: Int
}

struct ClearAction: Action {
}

struct LogUserAction: Action {
    let user: String
}
