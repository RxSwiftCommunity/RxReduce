//
//  AppMutators.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 2018-08-28.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

struct AppMutators {
    static let movieListMutator = Mutator<AppState, MovieListState>(lens: AppLenses.movieListLens, reducer: movieListReducer)
    static let movieDetailMutator = Mutator<AppState, MovieDetailState>(lens: AppLenses.movieDetailLens, reducer: movieDetailReducer)
}
