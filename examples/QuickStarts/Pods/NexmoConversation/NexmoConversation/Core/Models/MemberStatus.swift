//
//  MemberStatus.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 06/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Model for response of join/invite member request
internal struct MemberStatus: Decodable {
    
    // MARK:
    // MARK: Support
    
    private struct Channel: Decodable {
        private enum CodingKeys: String, CodingKey {
            case type
        }
        
        internal let type: MemberModel.Channel
        
        internal init(from decoder: Decoder) throws {
            type = try decoder.container(keyedBy: CodingKeys.self).decode(MemberModel.Channel.self, forKey: .type)
        }
    }
    
    // MARK:
    // MARK: Keys
    
    private enum CodingKeys: String, CodingKey {
        case state
        case id
        case userId = "user_id"
        case timestamp
        case channel
    }
    
    /// member id
    internal let memberId: String
    
    /// user id
    internal let userId: String
    
    /// member state
    internal let state: MemberModel.State
    
    /// timeStamp
    internal let timeStamp: Date
    
    /// member channel type
    internal let channel: MemberModel.Channel?
    
    // MARK:
    // MARK: Initializers
    
    internal init(from decoder: Decoder) throws {
        let allValues = try decoder.container(keyedBy: CodingKeys.self)
        let stateString = try allValues.decode(String.self, forKey: .state)
        
        guard let stateObject = MemberModel.State(rawValue: stateString.lowercased()) else {
            throw JSONError.malformedJSON
        }
        
        state = stateObject
        userId = try allValues.decode(String.self, forKey: .userId)
        memberId = try allValues.decode(String.self, forKey: .id)
        
        let timestampModel = try allValues.decode([String: String].self, forKey: .timestamp)
        
        guard let plainDate = timestampModel[stateObject.rawValue], let date = DateFormatter.ISO8601?.date(from: plainDate) else {
            throw JSONError.malformedJSON
        }
        
        timeStamp = date
        channel = try? allValues.decode(Channel.self, forKey: .channel).type
    }
}
