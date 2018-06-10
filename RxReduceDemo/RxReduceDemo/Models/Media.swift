//
//  Media.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-04-22.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation

protocol Media {
    var id: Int { get }
    var name: String { get }
    var overview: String { get }
    var popularity: Float { get }
    var genre: [Int] { get }
    var voteCount: Int { get }
    var voteAverage: Float { get }
    var posterPath: String { get }
    var backdropPath: String? { get }
    var originalLanguage: String { get }
    var originalName: String { get }
}
