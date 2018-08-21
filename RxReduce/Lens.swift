//
//  Lens.swift
//  RxReduce
//
//  Created by Thibault Wittemberg on 2018-08-20.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

import Foundation

public struct Lens<State, SubState> {
    let get: (State) -> SubState
    let set: (State, SubState) -> State
}
