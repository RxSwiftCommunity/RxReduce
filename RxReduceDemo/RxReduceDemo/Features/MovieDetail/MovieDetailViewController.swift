//
//  MovieDetailViewController.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-07.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage

class MovieDetailViewController: UIViewController, StoryboardBased, ViewModelBased {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var originalNameLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: MovieDetailViewModel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // ask the view model to load the movie detail and then listen to the state mutation
        self.viewModel.loadMovieDetail().drive(onNext: { [weak self] (movieDetailState) in
            self?.render(movieDetailState: movieDetailState)
        }).disposed(by: self.disposeBag)
    }

    private func render (movieDetailState: MovieDetailState) {
        switch movieDetailState {
        case .empty:
            self.posterImageView.image = nil
            self.nameLabel.text = "-"
            self.overviewTextView.text = "-"
            self.voteAverageLabel.text = "-"
            self.popularityLabel.text = "-"
            self.originalNameLabel.text = "-"
            self.releaseDateLabel.text = "-"
            self.activityIndicator.stopAnimating()
        case .loaded(let movie):
            self.activityIndicator.startAnimating()
            var posterPath = "https://image.tmdb.org/t/p/w780"+movie.posterPath
            if let backdropPath = movie.backdropPath {
                posterPath = "https://image.tmdb.org/t/p/w780"+backdropPath
            }
            Alamofire.request(posterPath).responseImage { [weak self] (response) in
                guard response.request?.url?.absoluteString == posterPath else { return }
                guard let data = response.data else { return }

                self?.posterImageView.image = UIImage(data: data)
                self?.activityIndicator.stopAnimating()
            }
            self.nameLabel.text = movie.name
            self.overviewTextView.text = movie.overview
            self.voteAverageLabel.text = "\(movie.voteAverage)"
            self.popularityLabel.text = "\(movie.popularity)"
            self.originalNameLabel.text = movie.originalName
            self.releaseDateLabel.text = movie.releaseDate
        }
    }

    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
