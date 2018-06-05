//
//  HasProtocols.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-04.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import RxReduce

protocol HasStore {
    var store: Store<AppState> { get }
}

protocol HasNetworkService {
    var networkService: NetworkService { get }
}
