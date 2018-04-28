//
//  IncreaseAction.swift
//  RxStateDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxState

struct IncreaseAction: Action {
    let increment: Int
}

struct DecreaseAction: Action {
    let decrement: Int
}

