//
//  AppDelegate.swift
//  RxReduceDemo
//
//  Created by Wittemberg, Thibault on 18-04-27.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import UIKit
import RxReduce
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let store = Store<DemoState>(withReducers: [counterReducer, usersReducer], withMiddlewares: [loggingMiddleware])
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let counterState: Driver<CounterState> = self.store.state { (demoState) -> CounterState in
            return demoState.counterState
        }

        let usersState: Driver<[String]> = self.store.state { (demoState) -> [String] in
            return demoState.usersState
        }

        counterState.drive(onNext: { (counterState) in
            print ("New counterState is \(counterState)")
        }).disposed(by: self.disposeBag)

        usersState.drive(onNext: { (usersState) in
            print ("New usersState is \(usersState)")
        }).disposed(by: self.disposeBag)

        // Dispatching a synchronous actions
        self.store.dispatch(action: IncreaseAction(increment: 10))
        self.store.dispatch(action: IncreaseAction(increment: 0))
        self.store.dispatch(action: AddUserAction(user: "Spock"))

//        // Dispatching a array of synchronous actions
//        let actions: [Action] = [IncreaseAction(increment: 10), IncreaseAction(increment: 5), DecreaseAction(decrement: 6)]
//        self.store.dispatch(action: actions)
//
//        // Dispatching an asynchronous action
//        let stopObservable = Observable<Int>.timer(10, scheduler: MainScheduler.instance)
//        let increaseAction = Observable<Int>.interval(1, scheduler: MainScheduler.instance).takeUntil(stopObservable).map { _ in IncreaseAction(increment: 1) }
//        self.store.dispatch(action: increaseAction)
//
//        // Dispatching an array of asynchronous actions
//        let decreaseAction = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { _ in DecreaseAction(decrement: 1) }
//        let asyncActions: [Action] = [increaseAction, decreaseAction]
//        self.store.dispatch(action: asyncActions)

        return true
    }

}

