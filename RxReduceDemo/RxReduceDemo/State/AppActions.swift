//
//  IncreaseAction.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

struct FetchMovieListAction: Action {}

struct LoadMovieListAction: Action {
    let movies: [DiscoverMovieModel]
}

struct LoadMovieDetailAction: Action {
    let movieId: Int
}

