//
//  NetworkService.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-02.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

final class NetworkService {

    let baseUrl: URL
    let apiKey: String

    init(withBaseUrl baseUrl: URL, andApiKey apiKey: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
    }

    func fetch<Model: Codable> (withRoute route: Route<Model>) -> Single<Model> {

        guard let url = route.getPath(forBaseUrl: self.baseUrl, andApiKey: self.apiKey) else {
            return Single.error(NSError(domain: "warpfactor.io", code: 404))
        }

        return Observable<Model>.create { (observer) -> Disposable in
            let request = Alamofire.request(url).responseData(completionHandler: { (response) in
                if let error = response.error {
                    observer.onError(error)
                    return
                }

                if  let data = response.data,
                    let model = try? JSONDecoder().decode(Model.self, from: data) {
                    observer.onNext(model)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "warpfactor.io", code: 404))
                }
            })

            return Disposables.create {
                request.cancel()
            }
        }.asSingle()
    }
}
