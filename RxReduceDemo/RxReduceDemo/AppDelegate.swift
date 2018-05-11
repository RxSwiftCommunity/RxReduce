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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let store = DefaultStore<DemoState>(withReducers: [demoReducer])
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.store.state.drive(onNext: { (state) in
            print ("New state is \(state)")
        }).disposed(by: self.disposeBag)

        // Dispatching a synchronous increase action
        self.store.dispatch(action: IncreaseAction(increment: 10))

        // Dispatching a array of synchronous actions
        let actions: [Action] = [IncreaseAction(increment: 10), IncreaseAction(increment: 5), DecreaseAction(decrement: 6)]
        self.store.dispatch(action: actions)

        // Dispatching an asynchronous action
        let stopObservable = Observable<Int>.timer(10, scheduler: MainScheduler.instance)
        let increaseAction = Observable<Int>.interval(1, scheduler: MainScheduler.instance).takeUntil(stopObservable).map { _ in IncreaseAction(increment: 1) }
        self.store.dispatch(action: increaseAction)

        // Dispatching an array of asynchronous actions
        let decreaseAction = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { _ in DecreaseAction(decrement: 1) }
        let asyncActions: [Action] = [increaseAction, decreaseAction]
        self.store.dispatch(action: asyncActions)

        return true
    }

}

