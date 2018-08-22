//
//  Error.swift
//  RxReduce
//
//  Created by Thibault Wittemberg on 2018-08-21.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

/// Error triggered by the Store
///
/// - mutatorAlreadyExist: triggered when trying to register a Mutator for a SubState that already has one
enum StoreError: Error {
    case mutatorAlreadyExist
}
