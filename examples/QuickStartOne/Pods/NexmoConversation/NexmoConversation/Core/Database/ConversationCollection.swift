//
//  ConversationCollection.swift
//  NexmoConversation
//
//  Created by shams ahmed on 29/03/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Collection of conversations
public class ConversationCollection: NexmoConversation.LazyCollection<Conversation> {

    /// Type of change 
    public typealias T = Change<Conversation, Reason>

    // MARK:
    // MARK: Enum

    /// Reason of change in a collection
    ///
    /// - new: new conversation from sync
    /// - invitedBy: new conversation received from a member invite
    /// - modified: collection was modified during sync
    public enum Reason: Equatable {
        case new
        case invitedBy(member: Member, withMedia: Conversation.Media?)
        case modified
    }

    /// Database manager
    internal weak var storage: Storage? {
        didSet {
            // Once the cache been set preload all uuids and conversations
            refetch()

            setup()
        }
    }

    /// Update subject value
    internal var value: T? {
        get {
            return subject.value
        }
        set {
            subject.value = newValue

            self.refetch()
        }
    }
    
    // MARK:
    // MARK: Properties - Observable
    
    /// Notification
    private let subject = Variable<T?>(nil)
    
    /// Observe for changes to collection
    public lazy var asObservable: Observable<T> = {
        // SKIP: inital value is from db to cache whereas this observable for new values
        return self.subject.asObservable().skip(1).unwrap().observeOnMainThread()
    }()
    
    // MARK:
    // MARK: Initializers
    
    /// Construct a collection of all (complete) conversations, sorted by date of most recent activity.
    internal init(storage: Storage?) {
        super.init()

        if let storage = storage {
            self.storage = storage

            setup()
        }
    }

    // MARK:
    // MARK: Setup

    private func setup() {
        
    }

    // MARK:
    // MARK: Collection

    internal func refetch() {
        guard let storage = storage else { return }
        
        uuids = storage.databaseManager.conversation.dataIncompleteUuids
    }

    // MARK:
    // MARK: Subscript
    
    /// Get conversation with uuid
    ///
    /// - Parameter uuid: conversation uuid
    public override subscript(_ uuid: String) -> Conversation? {
        return storage?.conversationCache.get(uuid: uuid)
    }
    
    /// Get conversation from position i
    ///
    /// - Parameter i: index
    public override subscript(_ i: Int) -> Conversation {
        guard let storage = storage else { fatalError("storage not been set yet") }
        guard uuids.count >= i, let conversation = storage.conversationCache.get(uuid: uuids[i]) else {
            fatalError("Collection out of bound")
        }
        
        return conversation
    }
}

// MARK:
// MARK: Compare

/// Compare to Reason values
/// :nodoc:
public func ==(lhs: ConversationCollection.Reason, rhs: ConversationCollection.Reason) -> Bool {
    switch (lhs, rhs) {
    case (.new, .new): return true
    case (.invitedBy(let l, _), .invitedBy(let r, _)): return l == r
    case (.modified, .modified): return true
    case (.new, _): return false
    case (.invitedBy, _): return false
    case (.modified, _): return false
    }
}
