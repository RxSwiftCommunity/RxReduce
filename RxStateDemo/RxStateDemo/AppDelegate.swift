//
//  AppDelegate.swift
//  RxStateDemo
//
//  Created by Wittemberg, Thibault on 18-04-27.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import UIKit
import RxState
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let store = DefaultStore<DemoState>(withReducers: [reducer])
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.store.state.subscribe(onNext: { (state) in
            print ("New state is \(state)")
        }).disposed(by: self.disposeBag)

        //        self.store.dispatch(action: IncreaseAction(increment: 10))

        let stopObservable = Observable<Int>.timer(10, scheduler: MainScheduler.instance)

        let increaseAction: Observable<Action> = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                                                                .takeUntil(stopObservable)
                                                                .map { _ in IncreaseAction(increment: 1) }

        let decreaseAction: Observable<Action> = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .map { _ in DecreaseAction(decrement: 1) }

        let asyncAtions: [Action] = [increaseAction, decreaseAction]

        self.store.dispatch(action: asyncAtions)

//        let actions: [Action] = [IncreaseAction(increment: 10), IncreaseAction(increment: 5), DecreaseAction(decrement: 6)]
//        self.store.dispatch(action: actions)

        return true
    }

}

