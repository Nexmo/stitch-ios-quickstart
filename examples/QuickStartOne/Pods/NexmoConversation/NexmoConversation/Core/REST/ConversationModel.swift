//
//  ConversationModel.swift
//  NexmoConversation
//
//  Created by James Green on 30/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Conversation model
@objc(NXMConversationModel)
public class ConversationModel: NSObject, Decodable {
    
    // MARK:
    // MARK: Keys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case cid
        case cname
        case name
        case sequence = "sequence_number"
        case members
        case timestamp
        case displayName = "display_name"
        case created
    }
    
    // MARK:
    // MARK: Properties

    /// Id
    public let uuid: String

    /// Name
    public let name: String

    /// Sequence number
    public let sequenceNumber: Int

    /// List of members
    public internal(set) var members: [MemberModel] = []
    
    /// Date of conversation been created
    public internal(set) var created: Date
    
    /// Display name
    public internal(set) var displayName: String
    
    // MARK:
    // MARK: Initializers

    internal init(uuid: String, name: String="", sequenceNumber: Int=0, members: [MemberModel]=[], created: Date, displayName: String="", state: MemberModel.State?, memberId: String?) {
        self.uuid = uuid
        self.name = name
        self.sequenceNumber = sequenceNumber
        self.members.append(contentsOf: members)
        self.created = created
        self.displayName = displayName
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
        members = try allValues.decode([MemberModel].self, forKey: .members)
        displayName = (try? allValues.decode(String.self, forKey: .displayName)) ?? ""
        
        guard let timestamp = (try allValues.decode([String: String].self, forKey: .timestamp))[CodingKeys.created.stringValue],
            let date = DateFormatter.ISO8601?.date(from: timestamp) else {
            throw JSONError.malformedJSON
        }
        
        created = date
    }
}

// MARK:
// MARK: Compare

/// Compare conversation model
/// :nodoc:
public func ==(lhs: ConversationModel, rhs: ConversationModel) -> Bool {
    return lhs.uuid == rhs.uuid
}
