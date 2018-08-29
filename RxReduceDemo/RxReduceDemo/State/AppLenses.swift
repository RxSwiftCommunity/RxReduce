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

    static let movieListLens = Lens<AppState, MovieListState>(get: { $0.movieListState }, set: { (appState, movieListState) -> AppState in
        var mutableState = appState
        mutableState.movieListState = movieListState
        return mutableState
    })

    static let movieDetailLens = Lens<AppState, MovieDetailState>(get: { $0.movieDetailState }, set: { (appState, detailState) -> AppState in
        var mutableState = appState
        mutableState.movieDetailState = detailState
        return mutableState
    })

}
