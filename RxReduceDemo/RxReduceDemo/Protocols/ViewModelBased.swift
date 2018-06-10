//
//  ViewModelBased.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-07.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import Foundation

protocol ViewModelBased {
    associatedtype ViewModelType: ViewModel

    var viewModel: ViewModelType! { get set }
}
