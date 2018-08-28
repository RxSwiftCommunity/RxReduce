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

        let increaseAction = IncreaseAction(increment: 10)

        let action = try increaseAction.toAsync().toBlocking().single()
        if let action = action as? IncreaseAction {
            XCTAssertEqual(10, action.increment)
        } else {
            XCTFail()
        }
    }

    func testAsynchronousAction () throws {

        let increaseAction = Observable<Action>.just(IncreaseAction(increment: 10))

        let action = try increaseAction.toAsync().toBlocking().single()
        if let action = action as? IncreaseAction {
            XCTAssertEqual(10, action.increment)
        } else {
            XCTFail()
        }
    }

    func testArrayOfActions () throws {

        let actions: [Action] = [IncreaseAction(increment: 10), IncreaseAction(increment: 20), IncreaseAction(increment: 30)]

        var initialIncrement = 10
        let actionsToTest = try actions.toAsync().toBlocking().toArray()

        actionsToTest.forEach {
            if let action = $0 as? IncreaseAction {
                XCTAssertEqual(initialIncrement, action.increment)
                initialIncrement += 10
            } else {
                XCTFail()
            }
        }
    }

    func testArrayOfActionsWithObservable () throws {

        let actions: [Action] = [IncreaseAction(increment: 10), Observable<Action>.just(IncreaseAction(increment: 20)), IncreaseAction(increment: 30)]

        var initialIncrement = 10
        let actionsToTest = try actions.toAsync().toBlocking().toArray()

        actionsToTest.forEach {
            if let action = $0 as? IncreaseAction {
                XCTAssertEqual(initialIncrement, action.increment)
                initialIncrement += 10
            } else {
                XCTFail()
            }
        }
    }
}
