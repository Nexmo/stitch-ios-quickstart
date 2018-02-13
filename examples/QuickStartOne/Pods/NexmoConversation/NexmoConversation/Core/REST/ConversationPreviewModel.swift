//
//  ConversationPreviewModel.swift
//  NexmoConversation
//
//  Created by James Green on 26/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Conversation preview model show a small preview of a conversation
@objc(NXMConversationPreviewModel)
public class ConversationPreviewModel: NSObject, Decodable {
    
    // MARK:
    // MARK: Enum
    
    private enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case cid
        case cname
        case name
        case sequence = "sequence_number"
        case state
        case memberIdUppercase = "member_Id"
        case memberIdLowercase = "member_id"
    }
    
    // MARK:
    // MARK: Properties
    
    /// Id
    public let uuid: String
    
    /// name
    public let name: String
    
    /// Sequence number
    public let sequenceNumber: Int

    /// Member Id
    public let memberId: String

    /// Member state
    public let state: MemberModel.State

    // MARK:
    // MARK: Initializers

    internal init(_ conversation: ConversationModel, for member: MemberModel) {
        uuid = conversation.uuid
        name = !conversation.displayName.isEmpty ? conversation.displayName : conversation.name
        sequenceNumber = conversation.sequenceNumber
        memberId = member.id
        state = member.state
    }

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let allValues = try decoder.container(keyedBy: CodingKeys.self)
        
        if allValues.contains(.id) {
            uuid = try allValues.decode(String.self, forKey: .id)
        } else if allValues.contains(.uuid) {
            uuid = try allValues.decode(String.self, forKey: .uuid)
        } else if allValues.contains(.cid) {
            uuid = try allValues.decode(String.self, forKey: .cid)
        } else if allValues.contains(.cname) {
            uuid = try allValues.decode(String.self, forKey: .cname)
        } else {
            throw JSONError.malformedJSON
        }

        name = try allValues.decode(String.self, forKey: .name)
        sequenceNumber = (try? allValues.decode(Int.self, forKey: .sequence)) ?? 0
        
        let stateString = try allValues.decode(String.self, forKey: .state).lowercased()
        
        guard let memberState = MemberModel.State(rawValue: stateString.lowercased()) else {
            throw JSONError.malformedJSON
        }
        
        state = memberState
        
        memberId = allValues.contains(.memberIdUppercase)
            ? try allValues.decode(String.self, forKey: .memberIdUppercase)
            : try allValues.decode(String.self, forKey: .memberIdLowercase)
    }
}

// MARK:
// MARK: Compare

/// compare conversation lite model
/// :nodoc:
public func ==(lhs: ConversationPreviewModel, rhs: ConversationPreviewModel) -> Bool {
    return lhs.uuid == rhs.uuid
}
