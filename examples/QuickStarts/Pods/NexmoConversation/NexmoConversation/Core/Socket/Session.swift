//
//  Session.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Session
public struct Session: Decodable {
    
    // MARK:
    // MARK: Keys
    
    private enum CodingKeys: String, CodingKey {
        case body
    }
    
    private enum BodyCodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
    }
    
    // MARK:
    // MARK: Properties
    
    /// Session id
    public let id: String
    
    /// User id
    public let userId: String
    
    /// Username/Email
    public let name: String
    
    // MARK:
    // MARK: JSON
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let allValues = try decoder.container(keyedBy: CodingKeys.self)
        let body = try allValues.nestedContainer(keyedBy: BodyCodingKeys.self, forKey: .body)
        
        id = try body.decode(String.self, forKey: .id)
        userId = try body.decode(String.self, forKey: .userId)
        name = try body.decode(String.self, forKey: .name)
    }
    
    internal init(id: String, userId: String, name: String) {
        self.id = id
        self.name = name
        self.userId = userId
    }
}
