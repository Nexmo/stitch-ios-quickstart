//
//  ReceiptRecord.swift
//  NexmoConversation
//
//  Created by James Green on 12/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Receipt Record
@objc(NXMReceiptRecord)
public class ReceiptRecord: NSObject {
    
    // MARK:
    // MARK: Enum
    
    // TODO: rename to Status
    /// Receipt State
    ///
    /// - sending: event is being sent
    /// - delivered: event has been delivered
    /// - seen: event has been seen
    @objc(NXMReceiptState)
    public enum ReceiptState: Int, Equatable {
        /// event is being sent
        case sending
        /// event has been delivered
        case delivered
        /// event has been seen
        case seen
    }
    
    // MARK:
    // MARK: Properties
    
    internal var data: DBReceipt
    
    /// Event
    public var event: EventBase {
        let uuid = EventBase.uuid(from: data.eventId, in: member.conversation.uuid)
        let event = ConversationClient.instance.storage.eventCache.get(uuid: uuid)
        
        return event!
    }
    
    /// Event state
    public var state: ReceiptState {
        if data.seenDate != nil {
            return .seen
        } else if data.deliveredDate != nil {
            return .delivered
        } else {
            return .sending
        }
    }
    
    /// List of members
    public var member: Member { return ConversationClient.instance.storage.memberCache.get(uuid: data.memberId)! }
    
    /// Date of receipt
    public internal(set) var date: Date? {
        get {
            if state == .seen {
                return data.seenDate
            } else if state == .delivered {
                return data.deliveredDate
            }
            
            return nil
        }
        set {
            if state == .seen {
                data.seenDate = newValue
            } else if state == .delivered {
                data.deliveredDate = newValue
            }
        }
    }
    
    // MARK:
    // MARK: Initializers
    
    internal init(data: DBReceipt) {
        self.data = data

        super.init()
    }
    
    // MARK:
    // MARK: Static - Helper
    
    internal static func UUIDtoMemberAndEvent(receiptUuid: String) -> (String, String) {
        let components = receiptUuid.components(separatedBy: ":")
        
        return (components[0], components[1])
    }
    
    internal static func memberAndEventToUUID(memberId: String, textEventId: String) -> String {
        return "\(memberId):\(textEventId)"
    }
}

// MARK:
// MARK: Compare

/// Compare ReceiptState
/// :nodoc:
public func ==(lhs: ReceiptRecord.ReceiptState, rhs: ReceiptRecord.ReceiptState) -> Bool {
    switch (lhs, rhs) {
    case (.sending, .sending): return true
    case (.delivered, .delivered): return true
    case (.seen, .seen): return true
    case (.sending, _),
         (.delivered, _),
         (.seen, _): return false
    }
}
