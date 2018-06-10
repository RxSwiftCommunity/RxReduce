| <img alt="RxReduce Logo" src="https://raw.githubusercontent.com/RxSwiftCommunity/RxReduce/develop/Resources/RxReduce_Logo.png" width="250"/> | <ul align="left"><li><a href="#about">About</a><li><a href="#architecture-concerns">Architecture concerns</a><li><a href="#rxreduce">RxReduce</a><li><a href="#installation">Installation</a><li><a href="#the-key-principles">The key principles</a><li><a href="#how-to-use-rxreduce">How to use RxReduce</a><li><a href="#tools-and-dependencies">Tools and dependencies</a></ul> |
| -------------- | -------------- |
| Travis CI | [![Build Status](https://travis-ci.org/RxSwiftCommunity/RxReduce.svg?branch=develop)](https://travis-ci.org/RxSwiftCommunity/RxReduce) |
| Frameworks | [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxReduce.svg?style=flat)](http://cocoapods.org/pods/RxReduce) |
| Platform | [![Platform](https://img.shields.io/cocoapods/p/RxReduce.svg?style=flat)](http://cocoapods.org/pods/RxReduce) |
| Licence | [![License](https://img.shields.io/cocoapods/l/RxReduce.svg?style=flat)](http://cocoapods.org/pods/RxReduce) |

<span style="float:none" />

# About
RxReduce is a Reactive implementation of the state container pattern (like Redux). It is based on the simple concepts of state immutability and unidirectionnal data flow.

# Architecture concerns
Since a few years there has been a lot, I mean a LOT, of blog posts, tutorials, books, conferences about adapting alternate architecture patterns to mobile applications. The idea behind all those patterns is to provide a better way to:

- meet the SOLID requirements ([Wikipedia](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design)))
- produce a safer code by design
- make our code more testable

The good old MVC tends to be replaced by MVP, MVVM or VIPER. I won't go into details about these ones as they are well documented. I think MVVM is currently the most trending pattern, mostly because of its similarities with MVC and MVP and its ability to leverage data binding to ease the data flow. Moreover it is pretty easy to be enhanced by a Coordinator pattern and Reactive programming.

Go check this project if you're interested in Reactive Coordinators ([RxFlow](https://github.com/RxSwiftCommunity/RxFlow)) 👌

That said, there is at least one other architecture pattern that stands out a little bit: **State Container**.

One of the most famous exemple is Redux, but let's not be restrained by a specific implementation.

Some resources about state containers:

- [State Container](https://jobandtalent.engineering/ios-architecture-an-state-container-based-approach-4f1a9b00b82e)
- [Unidirectional Data Flow](https://academy.realm.io/posts/benji-encz-unidirectional-data-flow-swift/)

The main goals of this pattern are to:

- expose a clear/reproductible data flow within your application
- rely on a single source of truth: the **state**
- leverage value types to handle the state immutability
- promote functional programming, as the only way to mutate a state is to apply a free function: **the reducer**

I find this approach very interesting compared to the more traditional ones, because it takes care of the consistency of your application state. MVC, MVP, MVVM or VIPER help you slice your application into well defined layers but they don't guide you so much when it comes to handle the state of your app.

Reactive programming is a great companion to state container architectures because it can help to:

- propage the state mutations
- build asynchronous actions to mutate the state (for networking, persistence, ...)

# RxReduce

RxReduce:

- provides a generic store that can handle all kinds of states
- exposes state mutation through a Reactive mechanism
- provides a simple/unified way to mutate the state synchronously and asynchronously via Actions

# Installation

## Carthage

In your Cartfile:

```ruby
github "RxSwiftCommunity/RxReduce"
```

## CocoaPods

In your Podfile:

```ruby
pod 'RxReduce'
```

# The key principles

The core mechanisms of **RxReduce** are very straightforward (if you know Redux, you won't be disturbed):

- the **Store** is the component that handles your state. It has only one input: the "**dispatch()**" function, that takes an **Action** as a parameter.
- The only way to trigger a **State** mutation is to call this "**dispatch()**" function.
- **Actions** are simple types with no business logic. They embed the payload needed to mutate the **state**
- Only free and testable functions called **Reducers** (RxReduce !) can mutate a **State**. A "**reduce()**" function takes a **State**, an **Action** and returns the new **State** ... that simple.
- You can have as many reducers as you want, they will be applied by the **Store**'s "**dispatch()**" function sequentially. It could be nice to have a reducer per business concern for instance.
- Reducers **cannot** perform asynchronous logic, they can only mutate the state in a synchronous and readable way. Asynchronous work will be taken care of by **Reactive Actions**.
- You can be notified of the state mutation thanks to a **Driver\<State\>** exposed by the **Store**.

# How to use RxReduce

## Code samples

### How to declare a **State**

As the main idea of state containers is about immutability, avoiding reference type uncontrolled propagation and race conditions, a **State** must be a value type. Structs and Enums are great for that.

```swift
import RxReduce

struct DemoState: State, Equatable {
    var counterState: CounterState
    var usersState: [String]
}

enum CounterState: Equatable {
    case empty
    case increasing (counter: Int)
    case decreasing (counter: Int)
    case stopped
}
```

Making states **Equatable** is not mandatory but it will allow the **Store** not to emit new state values if there is no change between 2 actions. So I strongly recommand to conform to Equatable to minimize the number of view refreshes.  

### How to declare **Actions**

Actions are simple data types that embed a payload used in the reducers to mutate the state.

```swift
import RxReduce

struct IncreaseAction: Action {
    let increment: Int
}

struct DecreaseAction: Action {
    let decrement: Int
}

struct AddUserAction: Action {
    let user: String
}
```

### How to declare **Reducers**

As I said, a **reducer** is a free function. These kind of functions takes a value, returns an idempotent value, and performs no side effects. Their declaration is not even related to a type definition. This is super convenient for testing 👍

Here we define 2 **reducers** that will be applied in sequence each time an Action is dispatched in the **Store**.

```swift
import RxReduce

func counterReducer (state: DemoState?, action: Action) -> DemoState {

    var currentState = state ?? DemoState(counterState: CounterState.empty, usersState: [])

    var currentCounter = 0

    // we extract the current counter value from the current state
    switch currentState.counterState {
    case .decreasing(let counter), .increasing(let counter):
        currentCounter = counter
    default:
        currentCounter = 0
    }

    // according to the action we create a new state
    switch action {
    case let action as IncreaseAction:
        currentState.counterState = .increasing(counter: currentCounter+action.increment)
        return currentState
    case let action as DecreaseAction:
        currentState.counterState = .decreasing(counter: currentCounter-action.decrement)
        return currentState
    default:
        return currentState
    }
}

func usersReducer (state: DemoState?, action: Action) -> DemoState {

    var currentState = state ?? DemoState(counterState: CounterState.empty, usersState: [])

    // according to the action we create a new state
    switch action {
    case let action as AddUserAction:
        currentState.usersState.append(action.user)
        return currentState
    default:
        return currentState
    }
}
```

Each of these **Reducers** will only handle the **Actions** it is responsible for, nothing less, nothing more. 

### How to declare a **Store**

**RxReduce** provides a concrete Store type. A Store needs at leat one **Reducer**:

```swift
let store = Store<DemoState>(withReducers: [counterReducer, usersReducer])
```

### How to declare a **Middleware**

Middlewares are very similar to Reducers BUT they cannot mutate the state. They are some kind of "passive observers" of what's being dispatched in the store. Middlewares can be used for logging, analytics, state recording, ...

```swift
import RxReduce

func loggingMiddleware (state: DemoState?, action: Action) {
    guard let state = state else {
        print ("A new Action \(action) will provide a first value for an empty state")
        return
    }

    print ("A new Action \(action) will mutate current State : \(state)")
}
```

A Store initializer takes Reducers and if needed, an Array of Middlewares as well:

```swift
let store = Store<DemoState>(withReducers: [counterReducer, usersReducer], withMiddlewares: [loggingMiddleware])
```

### Let's put the pieces all together

RxReduce allows to listen to the whole state or to some of its properties (we may call them **substates**).
Listening only to substates makes sense when the state begins to be huge and you do not want to be notified each time one of its portion has been modified.

First we pick the substate we want to observe (by passing a closure to the **store.state()** function):

```swift
let counterState: Driver<CounterState> = store.state { (demoState) -> CounterState in
    return demoState.counterState
}

let usersState: Driver<[String]> = store.state { (demoState) -> [String] in
    return demoState.usersState
}
```

The trailing closure gives you the whole state of the **Store**, and you just have to **extract** the substate you want to observe.

Then subscribe to the substate:

```swift
counterState.drive(onNext: { (counterState) in
    print ("New counterState is \(counterState)")
}).disposed(by: self.disposeBag)

usersState.drive(onNext: { (usersState) in
    print ("New usersState is \(usersState)")
}).disposed(by: self.disposeBag)
```

And now lets mutate the state:

```swift
store.dispatch(action: IncreaseAction(increment: 10))
store.dispatch(action: IncreaseAction(increment: 0))
store.dispatch(action: AddUserAction(user: "Spock"))
```

Please notice that the second action will not modify the state, and the **Store** will be smart about that and will not trigger a new value for the **counterState**. This happens only because **DemoState** conforms to **Equatable**.

The output will be:

```swift
New counterState is increasing(10) (for the first action)
New usersState is [] (for the first action)
New usersState is ["Spock"] (for the third action)
```

As we can see, **counterState** has received only one value 👌

## But wait, there's more ...

### List of actions

RxReduce is a lightweight framework. Pretty much everything is a protocol (except the Store, but if you want to implement you own Store it is perfectly fine since RxReduce provides a StoreType protocol you can conform to).

Lately, Swift 4.1 has introduced conditional conformance. If you are not familiar with this concept: [A Glance at conditional conformance](https://medium.com/@thibault.wittemberg/a-glance-at-conditional-conformance-c1f2d9ea29a3).

Basically it allows to make a generic type conform to a protocol only if the associated inner type also conforms to this protocol. 

For instance, RxReduce leverages this feature to make an Array of Actions be an Action to ! Doing so, it is perfectly OK to dispatch a list of actions to the Store like that:

```swift
let actions: [Action] = [IncreaseAction(increment: 10), DecreaseAction(increment: 5)]
store.dispatch(action: actions)
```

The actions declared in the array will be executed sequentially 👌.

### Asynchronicity

Making an Array of Actions be an Action itself is neat, but since we're using Reactive Programming, RxReduxe also applies this technic to Observables. It provides a very elegant way to dispatch an Observable\<Action\> to the Store (because Observable\<Action\> is also an Action), making asynchronous actions very simple. 

```swift
let increaseAction = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { _ in IncreaseAction(increment: 1) }
store.dispatch(action: increaseAction)
```

If we want to compare RxReduce with Redux, this ability to execute async actions would be equivalent to an "Action Creator".

For the record, we could even dispatch to the Store an Array of Observable\<Action\>, and it will be seen as an Action as well.

```swift
let increaseAction = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { _ in IncreaseAction(increment: 1) }
let decreaseAction = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { _ in DecreaseAction(decrement: 1) }
let asyncActions: [Action] = [increaseAction, decreaseAction]
store.dispatch(action: asyncActions)
```

Conditional Conformance is a very powerful feature.

## Demo Application

A demo application is provided to illustrate the core mechanisms, such as asynchronicity, sub states and view state rendering.

<table><tr><td><img style="border:2px solid black" width="200" alt="Demo Application" src="https://raw.githubusercontent.com/RxSwiftCommunity/RxReduce/develop/Resources/RxReduceDemo1.png"/></td>
<td><img style="border:2px solid black" width="200" alt="Demo Application" src="https://raw.githubusercontent.com/RxSwiftCommunity/RxReduce/develop/Resources/RxReduceDemo2.png"/></td></tr></table>

# Tools and dependencies

RxReduce relies on:

- SwiftLint for static code analysis ([Github SwiftLint](https://github.com/realm/SwiftLint))
- RxSwift to expose State and Actions as Observables your app and the Store can react to ([Github RxSwift](https://github.com/ReactiveX/RxSwift))
- Reusable in the Demo App to ease the storyboard cutting into atomic ViewControllers ([Github Reusable](https://github.com/AliSoftware/Reusable))
