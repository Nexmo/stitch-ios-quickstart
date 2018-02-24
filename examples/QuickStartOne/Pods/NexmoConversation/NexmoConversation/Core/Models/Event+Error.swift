//
//  EventError.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 04/04/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Extension for event error responses
internal extension Event {
    
    // MARK:
    // MARK: Enum
    
    private enum CodingKeys: String, CodingKey {
        case code
    }
    
    /// Event errors
    ///
    /// - eventNotFound: event not found
    /// - eventDeleted: event has been marked as deleted
    /// - unknown: other error not hard-coded in SDK
    internal enum Errors: String, Error {
        case eventNotFound = "event:error:not-found"
        case eventDeleted
        case unknown
        
        // MARK:
        // MARK: Builder

        /// Build error
        ///
        /// - Parameter raw: raw json response
        /// - Returns: Error
        internal static func build(_ raw: Data?) -> Errors {
            guard let data = raw,
                let code = (try? JSONDecoder().decode([String: String].self, from: data))?[CodingKeys.code.rawValue],
                let error = Errors(rawValue: code) else {
                return Errors.unknown
            }
            
            return error
        }
    }
}

// MARK:
// MARK: Compare

/// :nodoc:
internal func ==(lhs: Event.Errors, rhs: Event.Errors) -> Bool {
    switch (lhs, rhs) {
    case (.eventNotFound, .eventNotFound): return true
    case (.eventDeleted, .eventDeleted): return true
    case (.unknown, .unknown): return true
    case (.eventNotFound, _),
         (.eventDeleted, _),
         (.unknown, _): return false
    }
}
