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
    // MARK: Decode
    
    internal func decode<T>(_ type: T.Type, from object: [String: Any]?) throws -> T where T: Decodable {
        guard let object = object else { throw Errors.foundNilObject }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: object)
            
            return try decode(type, from: data)
        } catch let error {
            let description: String
            
            switch error as? DecodingError {
            case .dataCorrupted?:
                description = "dataCorrupted"
            case .keyNotFound(_, _)? where type == Event.Body.Deleted.self:
                throw error
            case .keyNotFound(let key, _)?:
                description = "keyNotFound: \(key)"
            case .typeMismatch(let type, _)?:
                description = "typeMismatch: \(type)"
            case .valueNotFound(let type, _)?:
                description = "valueNotFound: \(type)"
            default:
                switch error as? JSONError {
                case .malformedJSON? where isDeletedObject(object):
                    // Avoid logging a error for object deleting
                    throw error
                case .malformedJSON?:
                    description = "malformedJSON with: \(object.description)"
                case .malformedResponse?:
                    description = "malformedResponse with: \(object.description)"
                default:
                    description = "unknown"
                }
            }
            
            Log.info(.data, description + " for type: \(type)")
            
            throw error
        }
    }
    
    // MARK:
    // MARK: Helper
    
    private func isDeletedObject(_ object: [String: Any]) -> Bool {
        guard let data = try? JSONSerialization.data(withJSONObject: object),
            let _ = try? decode(Event.Body.Deleted.self, from: data) else {
            return false
        }
        
        return true
    }
}
