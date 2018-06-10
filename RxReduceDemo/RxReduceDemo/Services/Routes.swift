//
//  Routes.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-02.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import Alamofire

struct Route<Model> {
    let endpoint: String
    var id: Int?

    init (withEndpoint endpoint: String, withId id: Int? = nil) {
        self.endpoint = endpoint
        self.id = id
    }

    func getPath(forBaseUrl baseUrl: URL, andApiKey apiKey: String) -> URL? {
        var endpoint = self.endpoint
        if let id = self.id {
            endpoint = endpoint+"\(id)"
        }

        return URL(string: baseUrl.absoluteString+endpoint+"?api_key=\(apiKey)")
    }
}

struct Routes {
    static let discoverMovie = Route<DiscoverMovieResponse>(withEndpoint: "discover/movie")
    static let discoverTV = Route<DiscoverTVResponse>(withEndpoint: "discover/tv")
}
