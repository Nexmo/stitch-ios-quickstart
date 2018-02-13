//
//  EventResponse.swift
//  NexmoConversation
//
//  Created by shams ahmed on 11/10/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Response model from making a event request
internal struct EventResponse: Decodable {
    
    // MARK:
    // MARK: Key
    
    private enum CodingKeys: String, CodingKey {
        case id
        case href
        case timestamp
    }
    
    // MARK:
    // MARK: Properties
    
    /// ID of event from backend side
    internal let id: String
    
    /// Internal link used for primary id from backend database
    internal let href: String
    
    /// Timestamp of event
    internal let timestamp: Date
    
    // MARK:
    // MARK: Initializers
    
    internal init(from decoder: Decoder) throws {
        let allValues = try decoder.container(keyedBy: CodingKeys.self)
        
        id = "\(try allValues.decode(Int.self, forKey: .id))"
        href = try allValues.decode(String.self, forKey: .href)
        timestamp = try allValues.decode(Date.self, forKey: .timestamp)
    }
}
