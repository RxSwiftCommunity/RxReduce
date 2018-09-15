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

final class StoreTests: XCTestCase {

    private let disposeBag = DisposeBag()

    private let counterLens = Lens<TestState, CounterState> (get: { $0.counterState }) { (testState, counterState) -> TestState in
        var mutableTestState = testState
        mutableTestState.counterState = counterState
        return mutableTestState
    }

    private let userLens = Lens<TestState, UserState> (get: { $0.userState }) { (testState, userState) -> TestState in
        var mutableTestState = testState
        mutableTestState.userState = userState
        return mutableTestState
    }

    private lazy var store: Store<TestState> = {
        let store = Store<TestState>(withState: TestState(counterState: .empty, userState: .loggedOut))
        let counterMutator = Mutator<TestState, CounterState>(lens: counterLens, reducer: counterReduce)
        let userMutator = Mutator<TestState, UserState>(lens: userLens, reducer: userReduce)

        store.register(mutator: counterMutator)
        store.register(mutator: userMutator)

        return store
    }()

    override func tearDown() {
        do {
            _ = try store.dispatch(action: ClearAction()).toBlocking(timeout: 1).single()
        } catch {
            XCTFail(error.localizedDescription)
        }
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

    func testStateObservable () throws {
        let exp = expectation(description: "State Observable Expectation")

        let increaseAction = IncreaseAction(increment: 10)

        Observable.combineLatest(self.store.dispatch(action: increaseAction), self.store.state) { (newState1, newState2) -> (TestState, TestState) in
            return (newState1, newState2)
            }.subscribe(onNext: { (states) in
                guard states.0 == TestState(counterState: CounterState.increasing(10), userState: UserState.loggedOut) else {
                    return
                }
                
                if states.0 == states.1 {
                    exp.fulfill()
                }
            }).disposed(by: self.disposeBag)

        waitForExpectations(timeout: 1)
    }

    func testStoreSchedulers () throws {
        // create 2 queues: 1 for the observeOn part of the Rx stream, and 1 for the subscriveOn part
        let subscribeOnScheduler: OperationQueueScheduler = {
            let queue = OperationQueue()
            queue.name = "SUBSCRIBE_ON_QUEUE"
            queue.maxConcurrentOperationCount = 1
            return OperationQueueScheduler(operationQueue: queue)
        }()
        let observeOnScheduler: OperationQueueScheduler = {
            let queue = OperationQueue()
            queue.name = "OBSERVE_ON_QUEUE"
            queue.maxConcurrentOperationCount = 1
            return OperationQueueScheduler(operationQueue: queue)
        }()

        // Given
        let exp = expectation(description: "Queue expectation")
        exp.expectedFulfillmentCount = 3
        let actionObservable = Observable<Action>.just (IncreaseAction(increment: 10))

        // When
        actionObservable
            .map { action -> DecreaseAction in
                if let  queueName = OperationQueue.current?.name!,
                    queueName ==  "SUBSCRIBE_ON_QUEUE" {
                    exp.fulfill()
                } else {
                    XCTFail("Subscribe on Wrong Queue")
                }
                return DecreaseAction(decrement: 10)
            }
            .flatMap{ (action) -> Observable<CounterState> in

                if let  queueName = OperationQueue.current?.name!,
                    queueName ==  "SUBSCRIBE_ON_QUEUE" {
                    exp.fulfill()
                } else {
                    XCTFail("Subscribe on Wrong Queue")
                }
                return self.store.dispatch(action: action, focusingOn: { $0.counterState })
            }
            .subscribeOn(subscribeOnScheduler)
            .observeOn(observeOnScheduler)
            .subscribe(onNext: { counterState in

                if let  queueName = OperationQueue.current?.name!,
                    queueName ==  "OBSERVE_ON_QUEUE" {
                    exp.fulfill()
                } else {
                    XCTFail("Observe on Wrong Queue")
                }
            }).disposed(by: self.disposeBag)

        // Then
        waitForExpectations(timeout: 1)
    }
}
