//
//  ViewModelBased.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-07.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation

protocol ViewModelBased {
    associatedtype ViewModelType: ViewModel

    var viewModel: ViewModelType! { get set }
}
