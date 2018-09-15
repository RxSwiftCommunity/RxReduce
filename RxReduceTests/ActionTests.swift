//
//  RxReduceTests.swift
//  RxReduceTests
//
//  Created by Thibault Wittemberg on 18-04-22.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxBlocking
import RxReduce

class ActionTests: XCTestCase {

    let disposeBag = DisposeBag()

    func testSynchronousAction() throws {

        let increaseAction = AppAction.increase(increment: 10)

        let action = try increaseAction.toAsync().toBlocking().single()
        if case let AppAction.increase(increment) = action {
            XCTAssertEqual(10, increment)
        } else {
            XCTFail()
        }
    }

    func testAsynchronousAction () throws {

        let increaseAction = Observable<Action>.just(AppAction.increase(increment: 10))

        let action = try increaseAction.toAsync().toBlocking().single()
        if case let AppAction.increase(increment) = action {
            XCTAssertEqual(10, increment)
        } else {
            XCTFail()
        }
    }

    func testArrayOfActions () throws {

        let actions: [Action] = [AppAction.increase(increment: 10), AppAction.increase(increment: 20), AppAction.increase(increment: 30)]

        var initialIncrement = 10
        let actionsToTest = try actions.toAsync().toBlocking().toArray()

        actionsToTest.forEach {
            if case let AppAction.increase(increment) = $0 {
                XCTAssertEqual(initialIncrement, increment)
                initialIncrement += 10
            } else {
                XCTFail()
            }
        }
    }

    func testArrayOfActionsWithObservable () throws {

        let actions: [Action] = [AppAction.increase(increment: 10), Observable<Action>.just(AppAction.increase(increment: 20)), AppAction.increase(increment: 30)]

        var initialIncrement = 10
        let actionsToTest = try actions.toAsync().toBlocking().toArray()

        actionsToTest.forEach {
            if case let AppAction.increase(increment) = $0 {
                XCTAssertEqual(initialIncrement, increment)
                initialIncrement += 10
            } else {
                XCTFail()
            }
        }
    }
}
