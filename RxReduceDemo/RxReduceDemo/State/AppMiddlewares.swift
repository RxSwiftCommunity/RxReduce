//
//  Middlewares.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-05-20.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

func loggingMiddleware (state: AppState, action: Action) {
    print ("A new Action \(action) will mutate current State : \(state)")
}
