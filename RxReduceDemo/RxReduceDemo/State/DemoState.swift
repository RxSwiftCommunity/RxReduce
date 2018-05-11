//
//  DemoState.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

enum DemoState: State {
    case empty
    case increasing (counter: Int)
    case decreasing (counter: Int)
    case stopped
}
