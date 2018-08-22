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

        do {
            try store.register(mutator: counterMutator)
            try store.register(mutator: userMutator)
        } catch {
            XCTFail("Reducer registering failure")
        }

        return store
    }()

    override func tearDown() {
        store.dispatch(action: ClearAction()).subscribe().disposed(by: self.disposeBag)
    }

    func testSynchronousAction() {
        let exp = expectation(description: "synchronous subscription")

        let increaseAction = IncreaseAction(increment: 10)

        let subscription = store
            .dispatch(action: increaseAction)
            .subscribe(onNext: { (state) in
                let counterState = state.counterState
                let userState = state.userState

                XCTAssertEqual(userState, .loggedOut)
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

        let subscription = store
            .dispatch(action: increaseAction) { $0.counterState }
            .subscribe(onNext: { (counterState) in
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
            let userState = state.userState

            XCTAssertEqual(userState, .loggedOut)
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

        let exp = expectation(description: "Array subscription")

        let actions: [Action] = [IncreaseAction(increment: 10), Observable<Action>.just(DecreaseAction(decrement: 20)), LogUserAction(user: "Spock")]

        let subscription = store.dispatch(action: actions).subscribe(onNext: { (state) in

            if case let .increasing(value) = state.counterState {
                XCTAssertEqual(10, value)
            }

            if case let .decreasing(value) = state.counterState {
                XCTAssertEqual(-10, value)
            }

            if case let .loggedIn(user) = state.userState {
                XCTAssertEqual("Spock", user)
                exp.fulfill()
            }
        })

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }
    }

    func testMutatorRegistrationExhaustivity () {
        do {
            let counterMutator = Mutator<TestState, CounterState>(lens: counterLens, reducer: counterReduce)
            try self.store.register(mutator: counterMutator)
            XCTFail("Counter Reducer has already been registered, it should not be possible to register a new one")
        } catch {
            if let error = error as? StoreError {
                XCTAssertEqual(StoreError.mutatorAlreadyExist, error)
            }
        }
    }

    func testMiddlewares () {

        let exp = expectation(description: "Middleware subscription")

        let increaseAction = IncreaseAction(increment: 10)

        let middlewareStore = Store<TestState>(withState: TestState(counterState: .empty, userState: .loggedOut))

        let counterMutator = Mutator<TestState, CounterState>(lens: counterLens, reducer: counterReduce)
        let userMutator = Mutator<TestState, UserState>(lens: userLens, reducer: userReduce)

        do {
            try middlewareStore.register(mutator: counterMutator)
            try middlewareStore.register(mutator: userMutator)
        } catch {
            XCTFail("Reducer registering failure")
        }

        middlewareStore.register { (state, action) in
            exp.fulfill()
        }

        let subscription = middlewareStore.dispatch(action: increaseAction).subscribe()

        waitForExpectations(timeout: 1) { (_) in
            subscription.dispose()
        }

    }
}
