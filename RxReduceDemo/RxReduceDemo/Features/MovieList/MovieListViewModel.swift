//
//  MovieListViewModel.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-07.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce
import RxSwift
import RxCocoa

final class MovieListViewModel: ViewModel, Injectable {

    typealias InjectionContainer = HasStore & HasNetworkService
    var injectionContainer: InjectionContainer

    init(with injectionContainer: InjectionContainer) {
        self.injectionContainer = injectionContainer
    }

    func fetchMovieList () -> Driver<MovieListState> {
        // build an asynchronous action to fetch the movies
        let loadMovieAction: Observable<Action> = self.injectionContainer.networkService
            .fetch(withRoute: Routes.discoverMovie)
            .asObservable()
            .map { $0.movies }
            .map { LoadMovieListAction.init(movies: $0) }
            .startWith(FetchMovieListAction())

        // dispatch the asynchronous fetch action
        self.injectionContainer.store.dispatch(action: loadMovieAction)

        // listen for the store's state
        return self.injectionContainer.store.state { $0.movieListState }
    }
}
