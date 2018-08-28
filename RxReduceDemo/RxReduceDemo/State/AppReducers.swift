//
//  Reducers.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

func movieListReducer (state: AppState, action: Action) -> MovieListState {

    guard let action = action as? MovieAction else {
        return state.movieListState
    }

    switch action {
    case .startLoadingMovies:
        return .loading
    case .loadMovies(let movies):
        return .loaded(movies)
    default:
        return state.movieListState
    }
}

func movieDetailReducer (state: AppState, action: Action) -> MovieDetailState {

    guard let action = action as? MovieAction else {
        return state.movieDetailState
    }

    // according to the action we create a new state
    switch action {
    case .startLoadingMovies, .loadMovies(_):
        return .empty
    case .loadMovie(let movieId):
        guard case let .loaded(movies) = state.movieListState else { return state.movieDetailState }
        let movie = movies.filter { $0.id == movieId }.first
        if let movieDetail = movie {
            return .loaded(movieDetail)
        }
        return state.movieDetailState
    }
}
