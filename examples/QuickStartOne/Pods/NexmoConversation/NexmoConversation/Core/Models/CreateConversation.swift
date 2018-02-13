//
//  CreateConversation.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Gloss

/// Request model
internal extension ConversationService {

    // MARK:
    // MARK: Model

    /// Create a conversation request model
    internal struct CreateConversation: Gloss.JSONEncodable {

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

        internal func toJSON() -> JSON? {
            let model = ["display_name": displayName]
            
            return jsonify([model])
        }
    }
}
