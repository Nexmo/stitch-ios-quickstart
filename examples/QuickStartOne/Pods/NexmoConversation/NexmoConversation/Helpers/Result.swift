//
//  Result.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 22/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Completion block result
///
/// - success: result with T object
/// - failed: failed with error
public enum Result<T> {
    /// result with T object
    case success(T)
    /// failed with error
    case failed(Error)
}
