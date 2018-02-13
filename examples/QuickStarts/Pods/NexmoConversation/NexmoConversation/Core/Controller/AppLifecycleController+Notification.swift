//
//  AppLifecycleController+Notification.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 22/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Support for Notification
public extension AppLifecycleController {

    // MARK:
    // MARK: Enum

    /// Notification
    ///
    /// - conversation: covnersation notification with reason
    /// - text: text event notification
    /// - image: image event notification
    public enum Notification: Equatable {
        case conversation(ConversationCollection.T)
        case text(TextEvent)
        case image(ImageEvent)
    }
}

// MARK:
// MARK: Compare

/// Compare Notification reasons
/// :nodoc:
public func ==(lhs: AppLifecycleController.Notification, rhs: AppLifecycleController.Notification) -> Bool {
    switch (lhs, rhs) {
    case (.conversation(let l), .conversation(let r)):
        switch (l, r) {
        case (.inserted(let lConversation, _), .inserted(let rConversation, _)): return lConversation == rConversation
        case (.updated, .updated): return true
        case (.deleted, .deleted): return true
        case (.inserted, _): return false
        case (.updated, _): return false
        case (.deleted, _): return false
        }
    case (.text(let l), .text(let r)): return l == r
    case (.image(let l), .image(let r)): return l == r
    case (.conversation, _): return false
    case (.text, _): return false
    case (.image, _): return false
    }
}
