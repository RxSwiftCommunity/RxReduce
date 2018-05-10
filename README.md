| <img alt="RxReduce Logo" src="https://raw.githubusercontent.com/twittemb/RxReduce/develop/Resources/Rx RxReduce_Logo.png" width="250"/> | <ul align="left"><li><a href="#about">About</a><li><a href="#architecture-concerns">Architecture concerns</a><li><a href="#state-container-+-reactive-programming-=-rxreduce">State Container + Reactive Programming = RxReduce</a><li><a href="#installation">Installation</a><li><a href="#the-core-principles">The core principles</a><li><a href="#how-to-use-rxflow">How to use RxFlow</a><li><a href="#tools-and-dependencies">Tools and dependencies</a></ul> |
| -------------- | -------------- |
| Travis CI | [![Build Status](https://travis-ci.org/twittemb/RxReduce.svg?branch=develop)](https://travis-ci.org/twittemb/RxReduce) |
| Frameworks | [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxReduce.svg?style=flat)](http://cocoapods.org/pods/RxReduce) |
| Platform | [![Platform](https://img.shields.io/cocoapods/p/RxReduce.svg?style=flat)](http://cocoapods.org/pods/RxReduce) |
| Licence | [![License](https://img.shields.io/cocoapods/l/RxReduce.svg?style=flat)](http://cocoapods.org/pods/RxReduce) |

<span style="float:none" />

# About
RxReduce is a Reactive implementation of the state container pattern (like Redux). It is based on the simple concepts of state immutability and unidirectionnal data flow.

The Jazzy documentation can be seen here as well: [Documentation](http://community.rxswift.org/RxReduce/)

# Architecture concerns
Since a few years there has been a lot, I mean a LOT, of blogs posts, tutorials, books, conferences about adapting alternate architecture patterns to mobile applications. The idea behind all those patterns is to provide a better way to:

- meet the SOLID requirements [https://en.wikipedia.org/wiki/SOLID_(object-oriented_design)](Wikipedia)
- produce a safer code by design
- make our code more testable

The good old MVC tends to be replaced by MVP, MVVM or VIPER. I wont go into details about these ones as they are well documented. I think MVVM is currently the most trending pattern, mostly because of its similarities with MVC and MVP and its ability to leverage data binding to ease the data flow within an application. Moreover it is pretty easy to be enhanced by a Coordinator pattern and Reactive programming.

Go check this project if you're interested in Reactive Coordinators ([https://github.com/RxSwiftCommunity/RxFlow](RxFlow)) 👌

That being said, there is at least one other architecture pattern that stands out a little bit: **State Container**.

One of the most famous exemple is Redux, but let's not be restrained by specific implementation.

Some resources about state containers:

- [https://jobandtalent.engineering/ios-architecture-an-state-container-based-approach-4f1a9b00b82e](State Container)
- https://academy.realm.io/posts/benji-encz-unidirectional-data-flow-swift/ (Unidirectional Data Flow)

The main goals of such patterns are to:

- expose a clear/reproductible data flow within your application
- rely on a single source of truth: the **state**
- leverage value types to handle the state (im)mutability
- promote functional programming, as the only way to mutate a state is to apply a pure function: **the reducer**

I find this approach very interesting compared to the more traditional ones, because it takes care of the consistency of your application state. MVC, MVP, MVVM or VIPER help you slice your application into well defined layers but they don't guide you so much when it comes to handle the state of your app.

Reactive programming can also help a lot in multiple ways:

- handle state mutation propagation
- build asynchronous actions to mutate the state

# State Container + Reactive programming = RxReduce

RxReduce:

- provides a generic store that can handle all kinds of states
- exposes state mutation through a Reactive mechanism
- provides a simple way to mutate the state synchronously and asynchronously via Actions

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

The core mechanism is very straightforward:

- the **Store** is the component that handles your state. It has one function "dispatch" that will take an **Action** as a parameter.
- The only way to trigger a **State** mutation is to call this "dispatch" function.
- Actions are simple types with no business logic. They embed the payload needed to mutate the **state**
- Only simple, pure and testable functions called **Reducers** (RxReduce !) can mutate a **State**. A "reduce" function takes a **State**, an **Action** and returns the new **State** ... that simple.
- You can have as many reducers as you want, they will be applied by the **Store**'s "dispatch" function sequentially.
- Reducers **cannot** perform asynchronous logic. This kind of work will be taken care of by **Reactive Actions**.
- Finally, you can be notified of the state mutation thanks to a "RxCocoa" **Driver\<State\>** exposed by the **Store**.

# How to use RxReduce

## Code samples

### How to declare a **State**

### How to declare a **Store**

### How to declare an **Action**

### How to declare a **Reducer**

### Let's put the pieces all together


## Demo Application

A demo application is provided to illustrate the core mechanisms.

# Tools and dependencies

RxReduce relies on:

- SwiftLint for static code analysis ([Github SwiftLint](https://github.com/realm/SwiftLint))
- RxSwift to expose State and Actions as Observables the your app and the Store can react to ([Github RxSwift](https://github.com/ReactiveX/RxSwift))
- Reusable in the Demo App to ease the storyboard cutting into atomic ViewControllers ([Github Reusable](https://github.com/AliSoftware/Reusable))

