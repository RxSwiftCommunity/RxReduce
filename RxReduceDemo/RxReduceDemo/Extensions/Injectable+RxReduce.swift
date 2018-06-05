//
//  UIViewController+RxReduce.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-04.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation
import Reusable

extension Injectable where Self: StoryboardBased & UIViewController {
    static func instantiate(with injectionContainer: InjectionContainer) -> Self {
        var viewController = Self.instantiate()
        viewController.injectionContainer = injectionContainer
        return viewController
    }
}
