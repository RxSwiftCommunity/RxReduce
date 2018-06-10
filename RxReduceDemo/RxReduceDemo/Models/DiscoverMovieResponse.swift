//
//  DiscoverMovieResponse.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation

struct DiscoverMovieResponse: Codable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let movies: [DiscoverMovieModel]

    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case page
        case movies = "results"
    }
}

struct DiscoverMovieModel: Codable, Media, Equatable {
    let id: Int
    let video: Bool
    let name: String
    let overview: String
    let popularity: Float
    let adult: Bool
    let genre: [Int]
    let voteCount: Int
    let voteAverage: Float
    let posterPath: String
    let backdropPath: String?
    let originalLanguage: String
    let originalName: String
    let releaseDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case video
        case name = "title"
        case overview
        case popularity
        case adult
        case genre = "genre_ids"
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case originalName = "original_title"
        case releaseDate = "release_date"
    }
}
