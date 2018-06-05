//
//  Middlewares.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-05-20.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

func loggingMiddleware (state: AppState?, action: Action) {
    guard let state = state else {
        print ("A new Action \(action) will provide a first value for an empty state")
        return
    }

    print ("A new Action \(action) will mutate current State : \(state)")
}
