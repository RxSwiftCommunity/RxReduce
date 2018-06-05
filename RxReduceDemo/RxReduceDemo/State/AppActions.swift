//
//  IncreaseAction.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

struct FetchMovieListAction: Action {}

struct LoadMovieListAction: Action {
    let movies: [DiscoverMovieModel]
}

struct LoadMovieAction: Action {
    let movie:DiscoverMovieModel
}

