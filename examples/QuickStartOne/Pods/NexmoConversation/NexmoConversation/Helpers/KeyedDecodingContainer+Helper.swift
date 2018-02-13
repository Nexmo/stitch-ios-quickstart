//
//  KeyedDecodingContainer+Helper.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/01/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation

internal extension KeyedDecodingContainer {
    
    // MARK:
    // MARK: Errors
    
    /// Errors
    ///
    /// - invalidFormat: Value is not of Type
    internal enum Errors: Error {
        case invalidFormat
    }
    
    // MARK:
    // MARK: Date
    
    /// Decode ISO8601 dates
    internal func decode(_ type: Date.Type, forKey key: Key) throws -> Date {
        guard let formatter = DateFormatter.ISO8601 else { throw Errors.invalidFormat }
        
        let plainDate = try decode(String.self, forKey: key)
        
        guard let date = formatter.date(from: plainDate) else { throw Errors.invalidFormat }
        
        return date
    }
}
