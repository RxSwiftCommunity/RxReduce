//
//  DiscoverTVResponse.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-14.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation

struct DiscoverTVResponse: Codable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let shows: [DiscoverTVModel]

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case shows = "results"
    }
}

struct DiscoverTVModel: Codable, Media {
    let id: Int
    let name: String
    let overview: String
    let popularity: Float
    let genre: [Int]
    let voteCount: Int
    let voteAverage: Float
    let posterPath: String
    let backdropPath: String?
    let originalLanguage: String
    let originalName: String
    let firstAirDate: Date
    let originCountry: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case popularity
        case genre = "genre_ids"
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
    }
}
