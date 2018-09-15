//
//  Actions.swift
//  RxReduceTests
//
//  Created by Thibault Wittemberg on 18-06-11.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

enum AppAction: Action {
    case increase(increment: Int)
    case decrease(decrement: Int)
    case logUser(user: String)
    case clear
}
