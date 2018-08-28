//
//  AppLenses.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 2018-08-22.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

struct AppLenses {

    static let movieListLens = Lens<AppState, MovieListState> (get: { $0.movieListState }) { (appState, movieListState) -> MovieListState in
        var mutableAppState = appState
        mutableAppState.movieListState = movieListState
        return mutableAppState
    }

    static let movieDetailLens = Lens<AppState, MovieDetailState>(get: { $0.movieDetailState }) { (state, detailState) -> MovieDetailState in
        var mutableState = state
        mutableState.movieDetailState = detailState
        return mutableState
    }

}
