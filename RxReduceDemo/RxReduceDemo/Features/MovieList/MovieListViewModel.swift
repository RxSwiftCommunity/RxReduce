//
//  MovieListViewModel.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-07.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
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
            .map { $0.movies.filter {$0.backdropPath != nil } }
            .map { MovieAction.loadMovies(movies: $0) }
            .startWith(MovieAction.startLoadingMovies)

        // dispatch the asynchronous fetch action
        return self.injectionContainer
            .store
            .dispatch(action: loadMovieAction) { $0.movieListState }
            .asDriver(onErrorJustReturn: .empty)
    }
}
