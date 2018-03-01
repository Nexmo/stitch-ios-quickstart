//
//  EventBase.swift
//  NexmoConversation
//
//  Created by James Green on 06/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Event Base
@objc(NXMEventBase)
public class EventBase: NSObject {
    // TODO: remove such approach for swifty protocol oriented extensions
    
    // MARK:
    // MARK: Enum
    
    /// Event Type beng sent
    ///
    /// - text: Text event
    /// - image: Image event
    /// - membership: membership event
    @objc(NXMEventType)
    public enum EventType: Int {
        /// Text event
        case text
        /// Image event
        case image
        /// membership event
        case membership
    }
    
    // MARK:
    // MARK: Properties
    
    /// Database record
    internal var data: DBEvent
    
    /// Event Id
    internal var id: String { return data.id }
    
    /// Event uuid
    public var uuid: String { return EventBase.uuid(from: self.data.id, in: self.data.cid) }
    
    /// Conversation linked to this event
    public var conversation: Conversation {
        /// TODO: use DI
        return ConversationClient.instance.storage.conversationCache.get(uuid: data.cid)!
    }
    
    /// Creation date
    public var createDate: Date { return data.timestamp }
    
    /// Member who sent the event
    public var fromMember: Member {
        /// TODO: use DI
        return ConversationClient.instance.storage.memberCache.get(uuid: data.from!)!
    }

    internal var fromMemberForJoined: Member? {
        guard let from = data.from else { return nil }
        /// TODO: use DI
        return ConversationClient.instance.storage.memberCache.get(uuid: from)
    }
    
    private var _allReceipts: ReceiptCollection?

    /// All receipts
    public var allReceipts: ReceiptCollection {
        guard let receipts = _allReceipts else {
            let collection = ReceiptCollection(event: self, databaseManager: ConversationClient.instance.storage.databaseManager)

            _allReceipts = collection

            return collection
        }

        return receipts
    }

    /// List of members
    public var distribution: MemberCollection { return MemberCollection(event: self) }
    
    /// User who sent the event
    public var from: User { return self.fromMember.user }

    /// Flag to indicate event is in the process of being sent
    public var isCurrentlyBeingSent: Bool { return self.data.isDraft }

    // MARK:
    // MARK: Properties - Observable

    /// Observer to listen for changes in receipts
    public let receiptRecordChanged = Signal<ReceiptRecord>()

    /// Observer to listen for new receipts
    public let newReceiptRecord = Signal<ReceiptRecord>()

    // MARK:
    // MARK: NSObject
    
    /// :nodoc:
    public override var description: String {
        return String(format: "\(type(of: self)): \(data.id) in: \(data.cid)")
    }
    
    // MARK:
    // MARK: Initializers
    
    internal init(conversationUuid: String, event: Event, seen: Bool) {
        data = DBEvent(conversationUuid: conversationUuid, event: event, seen: seen)
        
        super.init()
    }
    
    internal init(data: DBEvent) {
        self.data = data
        
        super.init()
    }
    
    internal init(conversationUuid: String, type: Event.EventType, member: Member, seen: Bool) {
        data = DBEvent(conversationUuid: conversationUuid, type: type, memberId: member.data.rest.id, seen: seen)
        
        super.init()
    }

    // MARK:
    // MARK: Helper

    /// Fetch receipt from a member
    ///
    /// - Parameter member: member
    /// - Returns: record of receipt for this event
    public func receiptForMember(member: Member) -> ReceiptRecord? {
        return allReceipts[member]
    }

    internal func refreshReceipts() {
        // TODO: let avoid killing object, use refresh collection
        _allReceipts = ReceiptCollection(event: self, databaseManager: ConversationClient.instance.storage.databaseManager)
    }
    
    // MARK:
    // MARK: Static - Factory
    
    internal static func factory(conversationUuid: String, event: Event, seen: Bool) -> EventBase {
        switch event.type {
        case .text: return TextEvent(conversationUuid: conversationUuid, event: event, seen: seen)
        case .image: return ImageEvent(conversationUuid: conversationUuid, event: event, seen: seen)
        case .memberInvited: return MemberInvitedEvent(conversationUuid: conversationUuid, event: event, seen: seen)
        case .memberJoined: return MemberJoinedEvent(conversationUuid: conversationUuid, event: event, seen: seen)
        case .memberLeft: return MemberLeftEvent(conversationUuid: conversationUuid, event: event, seen: seen)
        case .memberMedia: return MediaEvent(conversationUuid: conversationUuid, event: event, seen: seen)
        default: return EventBase(conversationUuid: conversationUuid, event: event, seen: seen)
        }
    }
    
    internal static func factory(data: DBEvent) -> EventBase {
        switch data.type {
        case .text: return TextEvent(data: data)
        case .image: return ImageEvent(data: data)
        case .memberInvited: return MemberInvitedEvent(data: data)
        case .memberJoined: return MemberJoinedEvent(data: data)
        case .memberLeft: return MemberLeftEvent(data: data)
        case .memberMedia: return MediaEvent(data: data)
        default: return EventBase(data: data)
        }
    }
    
    // MARK:
    // MARK: Static - Helper
    
    /// Helper to go from a UUID to a conversation+event
    internal static func conversationEventId(from eventId: String) -> (/* conversation UUID */String, /* event id */String) {
        let components = eventId.components(separatedBy: ":")
        
        return (components[0], components[1])
    }
    
    /// Helper to go from a conversation+event to a UUID
    internal static func uuid(from eventId: String, in uuid: String) -> String {
        return "\(uuid):\(eventId)"
    }
}

// MARK:
// MARK: Compare

/// Compare wherever event is the same
///
/// - Parameters:
///   - lhs: event
///   - rhs: event
/// - Returns: result
/// :nodoc:
public func ==(lhs: EventBase, rhs: EventBase) -> Bool {
    return lhs.uuid == rhs.uuid
}
