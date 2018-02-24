//
//  JoinConversation.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Request model
internal extension ConversationController {

    // MARK:
    // MARK: Model

    /// Join a conversation request
    internal struct JoinConversation {
        
        // MARK:
        // MARK: Properties
        
        /// user id
        internal let userId: String
        
        /// action to perform
        private let action = MemberModel.Action.join
        
        /// channel
        private let channel = ["type": MemberModel.Channel.app.rawValue]
        
        /// member whom want to join, can be nil value
        internal let memberId: String?
        
        // MARK:
        // MARK: Initializers
        
        /// Create model
        internal init(userId: String, memberId: String?=nil) {
            self.userId = userId
            self.memberId = memberId
        }
        
        // MARK:
        // MARK: JSON
        
        internal var json: [String: Any] {
            var model: [String: Any] = [
                "user_id": userId,
                "action": action.rawValue,
                "channel": channel
            ]
            
            if let memberId = memberId {
                model["member_id"] = memberId
            }
            
            return model
        }
    }
}
