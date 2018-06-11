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
@testable import RxReduce

class ActionTests: XCTestCase {

    let disposeBag = DisposeBag()

    func testSynchronousAction() {

        let exp = expectation(description: "IncreaseAction")

        let increaseAction = IncreaseAction(increment: 10)

        increaseAction.toAsync().subscribe(onNext: { (action) in
            guard let action = action as? IncreaseAction else {
                XCTFail()
                return
            }
            XCTAssertEqual(10, action.increment)
            exp.fulfill()
        }).disposed(by: self.disposeBag)

        waitForExpectations(timeout: 1)
    }

    func testAsynchronousAction () {

        let exp = expectation(description: "IncreaseAction")

        let increaseAction = Observable<Action>.just(IncreaseAction(increment: 10))

        increaseAction.toAsync().subscribe(onNext: { (action) in
            guard let action = action as? IncreaseAction else {
                XCTFail()
                return
            }
            XCTAssertEqual(10, action.increment)
            exp.fulfill()
        }).disposed(by: self.disposeBag)

        waitForExpectations(timeout: 1)

    }

    func testArrayOfActions () {

        let exp = expectation(description: "IncreaseActions")
        exp.expectedFulfillmentCount = 3

        let actions: [Action] = [IncreaseAction(increment: 10), IncreaseAction(increment: 20), IncreaseAction(increment: 30)]

        var initialIncrement = 10
        actions.toAsync().subscribe(onNext: { (action) in
            guard let action = action as? IncreaseAction else {
                XCTFail()
                return
            }
            XCTAssertEqual(initialIncrement, action.increment)
            initialIncrement += 10
            exp.fulfill()
        }).disposed(by: self.disposeBag)

        waitForExpectations(timeout: 1)
    }

    func testArrayOfActionsWithObservable () {

        let exp = expectation(description: "IncreaseActions")
        exp.expectedFulfillmentCount = 3

        let actions: [Action] = [IncreaseAction(increment: 10), Observable<Action>.just(IncreaseAction(increment: 20)), IncreaseAction(increment: 30)]

        var initialIncrement = 10
        actions.toAsync().subscribe(onNext: { (action) in
            guard let action = action as? IncreaseAction else {
                XCTFail()
                return
            }
            XCTAssertEqual(initialIncrement, action.increment)
            initialIncrement += 10
            exp.fulfill()
        }).disposed(by: self.disposeBag)

        waitForExpectations(timeout: 1)
    }

}
