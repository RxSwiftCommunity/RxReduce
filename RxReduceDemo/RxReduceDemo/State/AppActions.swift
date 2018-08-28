//
//  IncreaseAction.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

enum MovieAction: Action {
    case startLoadingMovies
    case loadMovies (movies: [DiscoverMovieModel])
    case loadMovie (movieId: Int)
}
