//
//  DependencyContainer.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-04.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxReduce

final class DependencyContainer: HasStore, HasNetworkService {
    let store: Store<AppState>
    let networkService: NetworkService

    init(withStore store: Store<AppState>, withNetworkService networkService: NetworkService) {
        self.store = store
        self.networkService = networkService
    }
}
