//
//  StoreTests.swift
//  RxReduceTests
//
//  Created by Thibault Wittemberg on 18-06-11.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import RxReduce

class StoreTests: XCTestCase {

    let disposeBag = DisposeBag()
    let store = Store<TestState>(withReducers: [counterReducer, usersReducer])

    override func tearDown() {
        let clearActions: [Action] = [ClearCounterAction(), ClearUsersAction()]
        store.dispatch(action: clearActions)
    }

    func testSynchronousAction() {
        let exp = expectation(description: "synchronous subscription")
        exp.expectedFulfillmentCount = 1

        let increaseAction = IncreaseAction(increment: 10)

        let subscription = store.state().drive(onNext: { (state: TestState) in
            let counterState = state.counterState
            let users = state.users

            XCTAssert(users.isEmpty)
            guard case let .increasing(value) = counterState else {
                XCTFail()
                return
            }

            XCTAssertEqual(10, value)
            exp.fulfill()
        })

        store.dispatch(action: increaseAction)

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }
    }

    func testSubstateSubscription() {

        let exp = expectation(description: "Substate subscription")
        exp.expectedFulfillmentCount = 1

        let increaseAction = IncreaseAction(increment: 10)
        let doNothingAction = IncreaseAction(increment: 0)
        let addUserAction = AddUserAction(user: "Spock")

        let subscription = store.state { $0.counterState }.drive(onNext: { (counterState) in
            guard case let .increasing(value) = counterState else {
                XCTFail()
                return
            }

            XCTAssertEqual(10, value)
            exp.fulfill()
        })

        store.dispatch(action: increaseAction)
        store.dispatch(action: doNothingAction)
        store.dispatch(action: addUserAction)

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }
    }

    func testAsynchronousAction() {
        let exp = expectation(description: "asynchronous subscription")
        exp.expectedFulfillmentCount = 1

        let increaseAction = Observable<Action>.just(IncreaseAction(increment: 10)).subscribeOn(ConcurrentMainScheduler.instance).observeOn(ConcurrentMainScheduler.instance)

        let subscription = store.state().drive(onNext: { (state: TestState) in
            XCTAssertTrue(Thread.isMainThread)

            let counterState = state.counterState
            let users = state.users

            XCTAssert(users.isEmpty)
            guard case let .increasing(value) = counterState else {
                XCTFail()
                return
            }

            XCTAssertEqual(10, value)
            exp.fulfill()
        })

        store.dispatch(action: increaseAction)

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }
    }

    func testArrayOfActionsWithObservable () {

        let exp = expectation(description: "Array subscription")
        exp.expectedFulfillmentCount = 3

        let actions: [Action] = [IncreaseAction(increment: 10), Observable<Action>.just(DecreaseAction(decrement: 20)), AddUserAction(user: "Spock")]

        let subscriptionCounter = store.state { $0.counterState }.drive(onNext: { (counterState) in
            if case let .increasing(value) = counterState {
                XCTAssertEqual(10, value)
                exp.fulfill()
            }

            if case let .decreasing(value) = counterState {
                XCTAssertEqual(-10, value)
                exp.fulfill()
            }
        })

        let subscriptionUsers = store.state { $0.users }.drive(onNext: { (users) in
            if !users.isEmpty {
                XCTAssertEqual("Spock", users[0])
                exp.fulfill()
            }
        })

        store.dispatch(action: actions)

        waitForExpectations(timeout: 1) { (_) in
            subscriptionCounter.dispose()
            subscriptionUsers.dispose()
        }
    }
}
