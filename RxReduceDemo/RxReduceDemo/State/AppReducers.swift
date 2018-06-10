//
//  Reducers.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-28.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

func movieReducer (state: AppState?, action: Action) -> AppState {

    var currentState = state ?? AppState(movieListState: .empty, movieDetailState: .empty)

    // according to the action we create a new state
    switch action {
    case is FetchMovieListAction:
        currentState.movieListState = .loading
        currentState.movieDetailState = .empty
        return currentState
    case let action as LoadMovieListAction:
        currentState.movieListState = .loaded(action.movies)
        currentState.movieDetailState = .empty
        return currentState
    case let action as LoadMovieDetailAction:
        guard case let .loaded(movies) = currentState.movieListState else { return currentState }
        let movie = movies.filter { $0.id == action.movieId }.first
        if let movieDetail = movie {
            currentState.movieDetailState = .loaded(movieDetail)
        }
        return currentState
    default:
        return currentState
    }
}
