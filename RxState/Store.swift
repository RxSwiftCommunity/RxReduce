//
//  Store.swift
//  WarpFactorIOS
//
//  Created by Thibault Wittemberg on 18-04-15.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public typealias Reducer<StateType: State> = (_ state: StateType?, _ action: Action) -> StateType

public protocol Store {
    associatedtype StateType: State

    init(withReducers reducers: [Reducer<StateType>])

    var state: Observable<StateType> { get }

    func dispatch (action: Action)
}

public final class DefaultStore<StateType: State>: Store {

    let disposeBag = DisposeBag()

    private let stateSubject = BehaviorRelay<StateType?>(value: nil)
    public lazy var state: Observable<StateType> = { [unowned self] in
        return self.stateSubject.asObservable().filter { $0 != nil }.map { $0! }
        }()

    let reducers: [Reducer<StateType>]

    public init(withReducers reducers: [Reducer<StateType>]) {
        self.reducers = reducers
    }

    public func dispatch (action: Action) {

        action
            .toStream()
            .map { [unowned self] (action) -> StateType? in
                return self.reducers.reduce(self.stateSubject.value, { (currentState, reducer) -> StateType? in
                    return reducer(currentState, action)
                })
            }.subscribe(onNext: { [unowned self] (newState) in
                self.stateSubject.accept(newState)
            }).disposed(by: self.disposeBag)
    }
}
