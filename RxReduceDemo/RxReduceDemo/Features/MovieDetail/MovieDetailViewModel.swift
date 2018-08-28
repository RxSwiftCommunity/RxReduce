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

        // dispatch the synchronous Load Movie Detail action
        return self.injectionContainer
            .store
            .dispatch(action: MovieAction.loadMovie(movieId: self.movieId)) { $0.movieDetailState }
            .asDriver(onErrorJustReturn: MovieDetailState.empty)
    }

}
