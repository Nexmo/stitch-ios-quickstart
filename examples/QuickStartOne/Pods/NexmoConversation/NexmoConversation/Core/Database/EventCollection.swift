//
//  EventCollection.swift
//  NexmoConversation
//
//  Created by shams ahmed on 29/03/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Collection of event per conversation
@objc(NXMEventCollection)
public class EventCollection: NSObject, Collection {
    
    // MARK:
    // MARK: Enum
    
    /// Changes to event observer
    ///
    /// - reset: reset all events
    /// - inserts: inserted events at indexpath
    /// - deletes: deleted events at indexpath
    /// - updates: updated events at indexpath
    /// - move: moved events from and to
    /// - beginBatchEditing: begin batch editing
    /// - endBatchEditing: end batch editing
    public enum Change {
        case reset
        case inserts([IndexPath])
        case deletes([IndexPath])
        case updates([IndexPath])
        case move(IndexPath, IndexPath)
        case beginBatchEditing
        case endBatchEditing
    }
    
    // MARK:
    // MARK: Properties
    
    private let databaseManager: DatabaseManager
    private var conversationUuid: String
    private var eventCount: Int = 0
    
    /// Last event
    public var last: EventBase? {
        if eventCount > 0 {
            return self[eventCount - 1]
        }
        
        return nil
    }
    
    /// Start index
    public var startIndex: Int { return 0 }
    
    /// End index
    public var endIndex: Int { return eventCount }
    
    // MARK:
    // MARK: Properties - Observable
    
    public let newEventReceived = Signal<EventBase>()
    
    /// Notification of deleted event
    /// Returns event and type of changes that where made
    public let events = Signal<(events: [EventBase], change: Change)>()
    
    // MARK:
    // MARK: Initializers
    
    internal init(conversationUuid: String, databaseManager: DatabaseManager) {
        self.conversationUuid = conversationUuid
        self.databaseManager = databaseManager
        
        super.init()
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        eventCount = databaseManager.event[in: conversationUuid].count
    }
    
    // MARK:
    // MARK: Refresh
    
    internal func refresh() {
        setup()
    }
    
    // MARK:
    // MARK: Indexing
    
    /// Get index after a position
    ///
    /// - Parameter i: index
    /// - Returns: next position
    public func index(after i: Int) -> Int {
        guard i != endIndex else { fatalError("Cannot increment beyond endIndex") }
        
        return i + 1
    }
    
    // MARK:
    // MARK: Subscript
    
    /// Get Event from position i
    ///
    /// - Parameter i: index
    public subscript(i: Int) -> EventBase {
        let eventId = databaseManager.event[at: i, in: conversationUuid]?.id
        let uuid = EventBase.uuid(from: eventId!, in: conversationUuid)
        
        return ConversationClient.instance.storage.eventCache.get(uuid: uuid)!
    }
}
