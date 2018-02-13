//
//  CreateConversation.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Request model
internal extension ConversationService {

    // MARK:
    // MARK: Model

    /// Create a conversation request model
    internal struct CreateConversation {

        // MARK:
        // MARK: Properties

        /// Display name for conversation
        internal let displayName: String

        // MARK:
        // MARK: Initializers

        internal init(name displayName: String) {
            self.displayName = displayName
        }

        // MARK:
        // MARK: JSON

        internal var json: [String: String] {
            return ["display_name": displayName]
        }
    }
}
