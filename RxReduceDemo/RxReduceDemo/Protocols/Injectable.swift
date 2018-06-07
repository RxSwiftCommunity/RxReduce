//
//  UseCaseBased.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-04.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import Foundation

protocol Injectable {
    associatedtype InjectionContainer
    var injectionContainer: InjectionContainer { get set }
}
