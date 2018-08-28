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
import RxReduce
import RxBlocking

class StoreTests: XCTestCase {

    let disposeBag = DisposeBag()

    let counterLens = Lens<TestState, CounterState> (get: { $0.counterState }) { (testState, counterState) -> TestState in
        var mutableTestState = testState
        mutableTestState.counterState = counterState
        return mutableTestState
    }

    let userLens = Lens<TestState, UserState> (get: { $0.userState }) { (testState, userState) -> TestState in
        var mutableTestState = testState
        mutableTestState.userState = userState
        return mutableTestState
    }

    lazy var store: Store<TestState> = {
        let store = Store<TestState>(withState: TestState(counterState: .empty, userState: .loggedOut))
        let counterMutator = Mutator<TestState, CounterState>(lens: counterLens, reducer: counterReduce)
        let userMutator = Mutator<TestState, UserState>(lens: userLens, reducer: userReduce)

        store.register(mutator: counterMutator)
        store.register(mutator: userMutator)

        return store
    }()

    override func tearDown() {
        store.dispatch(action: ClearAction()).subscribe().disposed(by: self.disposeBag)
    }

    func testSynchronousAction() throws {

        let increaseAction = IncreaseAction(increment: 10)

        let state = try store
            .dispatch(action: increaseAction)
            .toBlocking()
            .single()

        XCTAssertEqual(state.userState, UserState.loggedOut)
        if case let .increasing(value) = state.counterState {
            XCTAssertEqual(10, value)
        } else {
            XCTFail()
        }
    }

    func testSubstateSubscription() throws {

        let increaseAction = IncreaseAction(increment: 10)

        let counterState = try store
            .dispatch(action: increaseAction) { $0.counterState }
            .toBlocking()
            .single()

        if case let .increasing(value) = counterState {
            XCTAssertEqual(10, value)
        } else {
            XCTFail()
        }
    }

    func testAsynchronousAction() throws {

        let increaseAction = Observable<Action>.just(IncreaseAction(increment: 10))

        let state = try store
            .dispatch(action: increaseAction)
            .toBlocking()
            .single()

        XCTAssertEqual(state.userState, UserState.loggedOut)
        if case let .increasing(value) = state.counterState {
            XCTAssertEqual(10, value)
        } else {
            XCTFail()
        }
    }

    func testArrayOfActionsWithObservable () throws {

        let actions: [Action] = [IncreaseAction(increment: 10), Observable<Action>.just(DecreaseAction(decrement: 20)), LogUserAction(user: "Spock")]

        let statesToTest = try store.dispatch(action: actions).toBlocking().toArray()

        statesToTest.forEach {
            if case let .increasing(value) = $0.counterState {
                XCTAssertEqual(10, value)
            }

            if case let .decreasing(value) = $0.counterState {
                XCTAssertEqual(-10, value)
            }

            if case let .loggedIn(user) = $0.userState {
                XCTAssertEqual("Spock", user)
            }
        }
    }

    func testMiddlewares () {

        let exp = expectation(description: "Middleware subscription")

        let increaseAction = IncreaseAction(increment: 10)

        let middlewareStore = Store<TestState>(withState: TestState(counterState: .empty, userState: .loggedOut))

        let counterMutator = Mutator<TestState, CounterState>(lens: counterLens, reducer: counterReduce)
        let userMutator = Mutator<TestState, UserState>(lens: userLens, reducer: userReduce)

        middlewareStore.register(mutator: counterMutator)
        middlewareStore.register(mutator: userMutator)

        middlewareStore.register { (state, action) in
            exp.fulfill()
        }

        let subscription = middlewareStore.dispatch(action: increaseAction).subscribe()

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }

    }
}
