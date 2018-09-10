//
//  AppDelegate.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-04.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import RxReduce
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let networkService: NetworkService = NetworkService(withBaseUrl: URL(string: "https://api.themoviedb.org/3/")!, andApiKey: "3afafd21270fe0414eb760a41f2620eb")
    private lazy var store: Store<AppState> = {
        let store = Store<AppState>(withState: AppState(movieListState: .empty, movieDetailState: .empty))

        store.register(mutator: AppMutators.movieListMutator)
        store.register(mutator: AppMutators.movieDetailMutator)
        
        return store
    }()

    lazy var dependencyContainer: DependencyContainer = {
        return DependencyContainer(withStore: self.store, withNetworkService: self.networkService)
    }()

    private let disposeBag = DisposeBag()

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard let window = self.window else { return false }

        // you can observe the State ... the same way you would do with a Middleware
        self.store.state.subscribe(onNext: { appState in
            print (appState)
        }).disposed(by: self.disposeBag)

        let movieListViewModel = MovieListViewModel(with: self.dependencyContainer)
        let movieListViewController = MovieListViewController.instantiate(with: movieListViewModel)
        window.rootViewController = movieListViewController
        window.makeKeyAndVisible()

        return true
    }

}

