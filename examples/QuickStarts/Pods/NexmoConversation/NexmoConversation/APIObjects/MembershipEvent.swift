//
//  MembershipEvent.swift
//  NexmoConversation
//
//  Created by James Green on 13/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Membership Event
@objc(NXMMembershipEvent)
public class MembershipEvent: EventBase {
    
    // MARK:
    // MARK: Keys
    
    fileprivate enum CodingKeys: String, CodingKey {
        case timestamp
        case user
        case invited = "invited_by"
    }
    
    fileprivate enum TimestampCodingKeys: String, CodingKey {
        case invited
        case joined
        case left
    }
}

/// Invite Membership Event
@objc(NXMMemberInvitedEvent)
public class MemberInvitedEvent: MembershipEvent {
    
    // MARK:
    // MARK: Properties
    
    /// Invited date
    public internal(set) lazy var invitedDate: Date? = {
        let allValues = try? JSONDecoder().decode([String: String].self, from: self.data.body)
        
        guard let date = DateFormatter.ISO8601?.date(from: allValues?[TimestampCodingKeys.invited.rawValue] ?? "")else {
            return nil
        }
        
        return date
    }()
    
    /// Member who been invited to conversation
    public internal(set) lazy var invitedMember: Member? = {
        guard let json = self.data.body[CodingKeys.user.rawValue] as? [String: Any],
            let member = try? MemberModel(json: json, state: .invited) else {
            return nil
        }
        
        return Member(conversationUuid: self.uuid, member: member)
    }()
    
    /// invited by user
    public internal(set) lazy var invitedBy: String? = { return self.data.body[CodingKeys.invited.rawValue] as? String }()
}

/// Join Membership Event
@objc(NXMMemberJoinedEvent)
public class MemberJoinedEvent: MembershipEvent {

    // MARK:
    // MARK: Properties
    
    /// Join date
    public internal(set) lazy var joinedDate: Date? = {
        let allValues = try? JSONDecoder().decode([String: String].self, from: self.data.body)
        
        guard let date = DateFormatter.ISO8601?.date(from: allValues?[TimestampCodingKeys.joined.rawValue] ?? "")else {
            return nil
        }
        
        return date
    }()
}

/// Left Membership Event
@objc(NXMMemberLeftEvent)
public class MemberLeftEvent: MembershipEvent {
    
    // MARK:
    // MARK: Properties
    
    /// Lefted date
    public internal(set) lazy var leftDate: Date? = {
        let allValues = try? JSONDecoder().decode([String: String].self, from: self.data.body)
        
        guard let date = DateFormatter.ISO8601?.date(from: allValues?[TimestampCodingKeys.invited.rawValue] ?? "")else {
            return nil
        }
        
        return date
    }()
}
