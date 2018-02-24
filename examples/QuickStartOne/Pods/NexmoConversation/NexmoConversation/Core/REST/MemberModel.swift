//
//  MemberModel.swift
//  NexmoConversation
//
//  Created by James Green on 30/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

// TODO: a model should not be mutable remove all var on this class, other classes need to recreate a struct object to avoid any weird issue
/// Member model
public struct MemberModel: Decodable {
    
    // MARK:
    // MARK: Enum

    private enum CodingKeys: String, CodingKey {
        case memberId = "member_id"
        case name
        case state
        case userId = "user_id"
        case invitedBy = "invited_by"
        case timestamp
    }
    
    /// Member State
    ///
    /// - joined: Member is joined to this conversation
    /// - invited: Member has been invited to this conversation
    /// - left: Member has left this conversation
    /// - unknown: Unknown state, must be a force resync
    public enum State: String, EnumCollection {
        /// Member is joined to this conversation
        case joined
        /// Member has been invited to this conversation
        case invited
        /// Member has left this conversation
        case left
        /// Unknown state, must be a force resync
        case unknown
        
        // MARK:
        // MARK: Helper
        
        internal var intValue: Int32 {
            switch self {
            case .joined: return 0
            case .invited: return 1
            case .left: return 2
            case .unknown: return 3
            }
        }
        
        internal static func from(_ int32: Int32) -> State? {
            switch int32 {
            case 0: return .joined
            case 1: return .invited
            case 2: return .left
            case 3: return .unknown
            default: return nil
            }
        }
    }
    
    /// Action a member can perform or be in a state
    ///
    /// - invite: member requested to be invited
    /// - join: member requested to join
    internal enum Action: String, Equatable {
        /// member requested to be invited
        case invite
        /// member requested to join
        case join
    }
    
    /// Channel type member receives messages
    ///
    /// - APP: SDK
    /// - SIP: sip
    /// - PSTN: pstn
    /// - SMS: sms
    /// - OTT: ott
    public enum Channel: String, Equatable, Decodable {
        /// SDK
        case app
        /// sip
        case sip
        /// pstn
        case pstn
        /// sms
        case sms
        /// ott
        case ott
    }
    
    // MARK:
    // MARK: Properties
    
    /// Member iD
    public internal(set) var id: String
    
    /// Name
    public internal(set) var name: String
    
    /// State
    public internal(set) var state: State
    
    /// User id
    public internal(set) var userId: String

    /// User who has invited this member
    public let invitedBy: String?

    /// Timestamp of when user joined
    public internal(set) var timestamp: [State: Date?]

    // MARK:
    // MARK: Initializers

    internal init(
        _ memberId: String,
        name: String, 
        state: State,
        userId: String, 
        invitedBy: String?, 
        timestamp: [State: Date?]) {
        self.id = memberId
        self.name = name
        self.state = state
        self.userId = userId
        self.invitedBy = invitedBy
        self.timestamp = timestamp
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let allValues = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try allValues.decode(String.self, forKey: .memberId)
        name = try allValues.decode(String.self, forKey: .name)
        userId = try allValues.decode(String.self, forKey: .userId)
        invitedBy = try allValues.decodeIfPresent(String.self, forKey: .invitedBy)
        
        let stateString = try allValues.decode(String.self, forKey: .state)
        
        guard let stateObject = State(rawValue: stateString.lowercased()) else {
            throw JSONError.malformedJSON
        }

        state = stateObject
        
        let timestamps = try allValues.decode([String: String].self, forKey: .timestamp)
        
        timestamp = [
            State.invited: DateFormatter.ISO8601?.date(from: timestamps[State.invited.rawValue] ?? ""),
            State.joined: DateFormatter.ISO8601?.date(from: timestamps[State.joined.rawValue] ?? ""),
            State.left: DateFormatter.ISO8601?.date(from: timestamps[State.left.rawValue] ?? "")
        ]
    }
    
    internal init(json: [String: Any], state: State) throws {
        guard let memberId = json["member_id"] as? String else { throw JSONError.malformedJSON }
        guard let name = json["name"] as? String else { throw JSONError.malformedJSON }
        guard let userId = json["user_id"] as? String else { throw JSONError.malformedJSON }

        self.id = memberId
        self.name = name
        self.state = state
        self.userId = userId
        self.invitedBy = json["invited_by"] as? String
        
        let timestamps = json["timestamp"] as? [String: String]
        
        timestamp = [
            State.invited: DateFormatter.ISO8601?.date(from: timestamps?[State.invited.rawValue] ?? ""),
            State.joined: DateFormatter.ISO8601?.date(from: timestamps?[State.joined.rawValue] ?? ""),
            State.left: DateFormatter.ISO8601?.date(from: timestamps?[State.left.rawValue] ?? "")
        ]
    }

    // MARK:
    // MARK: Date

    /// Date that a member's state changed
    ///
    /// - parameter state: Member.State
    ///
    /// - returns: date of reaching this member state
    public func date(of state: MemberModel.State) -> Date? {
        guard let date = timestamp[state] else { return nil }

        return date
    }
}

// MARK:
// MARK: Compare

/// Compare wherever member state are the same
///
/// - Parameters:
///   - lhs: member state
///   - rhs: member state
/// - Returns: result
/// :nodoc:
public func ==(lhs: MemberModel.State, rhs: MemberModel.State) -> Bool {
    switch (lhs, rhs) {
    case (.joined, .joined): return true
    case (.invited, .invited): return true
    case (.left, .left): return true
    case (.unknown, .unknown): return true
    case (.joined, _),
         (.invited, _),
         (.left, _),
         (.unknown, _): return false
    }
}

/// Compare Action
/// :nodoc:
internal func ==(lhs: MemberModel.Action, rhs: MemberModel.Action) -> Bool {
    switch (lhs, rhs) {
    case (.invite, .invite): return true
    case (.join, .join): return true
    case (.invite, _),
         (.join, _): return false
    }
}

/// Compare Channel
/// :nodoc:
public func ==(lhs: MemberModel.Channel, rhs: MemberModel.Channel) -> Bool {
    switch (lhs, rhs) {
    case (.app, .app): return true
    case (.sip, .sip): return true
    case (.pstn, .pstn): return true
    case (.sms, .sms): return true
    case (.ott, .ott): return true
    case (.app, _),
         (.sip, _),
         (.pstn, _),
         (.sms, _),
         (.ott, _): return false
    }
}
