//
//  MovieListViewController.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-04.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import RxReduce
import Alamofire
import AlamofireImage

final class MovieListViewController: UITableViewController, StoryboardBased, Injectable {

    typealias InjectionContainer = HasStore & HasNetworkService
    var injectionContainer: InjectionContainer!

    private let disposeBag = DisposeBag()

    private var movies = [DiscoverMovieModel]()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.hidesWhenStopped = true
        indicator.color = .black
        indicator.frame = self.view.frame

        self.view.addSubview(indicator)
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.tableView.register(cellType: MovieListViewCell.self)

        // build an asynchronous action to fetch the movies
        let loadMovieAction: Observable<Action> = self.injectionContainer.networkService
            .fetch(withRoute: Routes.discoverMovie)
            .asObservable()
            .map { $0.movies }
            .map { LoadMovieListAction.init(movies: $0) }
            .startWith(FetchMovieListAction())

        // listen for the store's state
        let movieListState = self.injectionContainer.store.state { (appState) -> MovieListState in
            return appState.movieListState
        }

        // update the view according to the state
        movieListState.drive(onNext: { [weak self] (movieListState) in
            self?.render(movieListState: movieListState)
        }).disposed(by: self.disposeBag)

        // dispatch the asynchronous fetch action
        self.injectionContainer.store.dispatch(action: loadMovieAction)
    }

    private func render (movieListState: MovieListState) {
        switch movieListState {
        case .empty:
            self.movies.removeAll()
            self.activityIndicator.stopAnimating()
        case .loading:
            self.movies.removeAll()
            self.activityIndicator.isHidden = false
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            self.activityIndicator.startAnimating()
        case .loaded(let movies):
            self.movies = movies
            self.tableView.isHidden = false
            self.activityIndicator.stopAnimating()
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieListViewCell = tableView.dequeueReusableCell(for: indexPath)
        let movie = self.movies[indexPath.row]
        cell.title.text = movie.name
        cell.overview.text = movie.overview
        let posterPath = "https://image.tmdb.org/t/p/w154"+movie.posterPath
        Alamofire.request(posterPath).responseImage { (response) in
            guard response.request?.url?.absoluteString == posterPath else { return }
            guard let data = response.data else { return }

            cell.poster.image = UIImage(data: data)
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
