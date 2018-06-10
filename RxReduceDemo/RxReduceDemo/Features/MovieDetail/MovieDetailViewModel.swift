//
//  MovieDetailViewModel.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-07.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce
import RxSwift
import RxCocoa

final class MovieDetailViewModel: ViewModel, Injectable {
    typealias InjectionContainer = HasStore
    var injectionContainer: InjectionContainer
    
    let movieId: Int

    init(with injectionContainer: InjectionContainer, withMovieId movieId: Int) {
        self.injectionContainer = injectionContainer
        self.movieId = movieId
    }

    func loadMovieDetail () -> Driver<MovieDetailState> {

        // build a synchronous action to pick the movie
        let loadMovieDetailAction = LoadMovieDetailAction(movieId: self.movieId)

        // dispatch the synchronous Load Movie Detail action
        self.injectionContainer.store.dispatch(action: loadMovieDetailAction)

        // listen for the store's state
        return self.injectionContainer.store.state { $0.movieDetailState }
    }

}
