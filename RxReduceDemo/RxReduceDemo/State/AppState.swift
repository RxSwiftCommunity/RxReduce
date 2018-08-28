//
//  AppState.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

struct AppState: Equatable {
    var movieListState: MovieListState
    var movieDetailState: MovieDetailState
}

enum MovieListState: Equatable {
    case empty
    case loading
    case loaded ([DiscoverMovieModel])
}

enum MovieDetailState: Equatable {
    case empty
    case loaded (DiscoverMovieModel)
}
