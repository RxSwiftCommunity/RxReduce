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
    let store = Store<TestState>(withState: TestState(counterState: .empty, users: [String]()),withReducers: [counterReducer, usersReducer])

    override func tearDown() {
        let clearActions: [Action] = [ClearCounterAction(), ClearUsersAction()]
        store.dispatch(action: clearActions).subscribe().disposed(by: self.disposeBag)
    }

    func testSynchronousAction() {
        let exp = expectation(description: "synchronous subscription")

        let increaseAction = IncreaseAction(increment: 10)

        let subscription = store.dispatch(action: increaseAction).subscribe(onNext: { (state) in
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

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }
    }

    func testSubstateSubscription() {

        let exp = expectation(description: "Substate subscription")
        exp.expectedFulfillmentCount = 1

        let increaseAction = IncreaseAction(increment: 10)

        let subscription = store.dispatch(action: increaseAction) { $0.counterState }.subscribe(onNext: { (counterState) in
            guard case let .increasing(value) = counterState else {
                XCTFail()
                return
            }

            XCTAssertEqual(10, value)
            exp.fulfill()
        })

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }
    }

    func testAsynchronousAction() {
        let exp = expectation(description: "asynchronous subscription")

        let increaseAction = Observable<Action>.just(IncreaseAction(increment: 10)).subscribeOn(ConcurrentMainScheduler.instance).observeOn(ConcurrentMainScheduler.instance)

        let subscription = store.dispatch(action: increaseAction).subscribe(onNext: { (state) in
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

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }
    }

    func testArrayOfActionsWithObservable () {

        struct SubState: Equatable {
            let counterState: CounterState
            let users: [String]
        }

        let exp = expectation(description: "Array subscription")

        let actions: [Action] = [IncreaseAction(increment: 10), Observable<Action>.just(DecreaseAction(decrement: 20)), AddUserAction(user: "Spock")]

        let subscription = store.dispatch(action: actions) { state -> SubState in return SubState(counterState: state.counterState, users: state.users) }.subscribe(onNext: { (subState) in
            print (subState)
            if case let .increasing(value) = subState.counterState {
                XCTAssertEqual(10, value)
            }

            if case let .decreasing(value) = subState.counterState {
                XCTAssertEqual(-10, value)
            }

            if !subState.users.isEmpty {
                XCTAssertEqual("Spock", subState.users[0])
                exp.fulfill()
            }
        })

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }
    }

    func testMiddleware () {

        let exp = expectation(description: "Middleware subscription")

        let increaseAction = IncreaseAction(increment: 10)

        let testStore = Store<TestState>(withState: TestState(counterState: .empty, users: [String]()),withReducers: [counterReducer, usersReducer], withMiddlewares: [{ state, action in
                exp.fulfill()
        }])

        let subscription = testStore.dispatch(action: increaseAction).subscribe()

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }

    }
}
