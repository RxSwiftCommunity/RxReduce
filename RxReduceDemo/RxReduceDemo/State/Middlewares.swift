//
//  Middlewares.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-05-20.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

func loggingMiddleware (state: DemoState?, action: Action) {
    print ("A new Action \(action) will nutate current State : \(state)")
}
