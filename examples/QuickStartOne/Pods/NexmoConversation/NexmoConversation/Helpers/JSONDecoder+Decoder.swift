//
//  JSONDecoder+Decoder.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 03/01/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation

internal extension JSONDecoder {
    
    // MARK:
    // MARK: Error
    
    internal enum Errors: Error {
        case foundNilObject
    }
    
    // MARK:
    // MARK: Decode Optional
    
    internal func decode<T>(_ type: T.Type, from object: [String: AnyObject]?) throws -> T where T: Decodable {
        guard let object = object else { throw Errors.foundNilObject }
        
        return try decode(type, from: object)
    }
    
    internal func decode<T>(_ type: T.Type, from object: [String: Any]?) throws -> T where T: Decodable {
        guard let object = object else { throw Errors.foundNilObject }
        
        return try decode(type, from: object)
    }
    
    // MARK:
    // MARK: Decode
    
    internal func decode<T>(_ type: T.Type, from object: [String: AnyObject]) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: object)
        
        return try decode(type, from: data)
    }
    
    internal func decode<T>(_ type: T.Type, from object: [String: Any]) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: object)
        
        return try decode(type, from: data)
    }
}
