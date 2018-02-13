//
//  JSONError.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 18/01/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation

/// JSON Errors
///
/// - malformedJSON: json key:value does not match decoder
/// - malformedResponse: unknown response from network
internal enum JSONError: Error {
    case malformedJSON
    case malformedResponse
}
