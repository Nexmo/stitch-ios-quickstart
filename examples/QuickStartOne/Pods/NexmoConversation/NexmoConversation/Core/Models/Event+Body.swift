//
//  Body+Text.swift
//  NexmoConversation
//
//  Created by shams ahmed on 22/06/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Gloss

/// Body models
internal extension Event.Body {
    
    // MARK:
    // MARK: Text
    
    /// Text model
    internal struct Text: Gloss.JSONDecodable {
        
        /// Text
        internal let text: String
        
        // MARK:
        // MARK: Initializers

        internal init?(json: JSON) {
            guard let text: String = "text" <~~ json else { return nil }
            
            self.text = text
        }
    }
    
    // MARK:
    // MARK: Delete
    
    /// Delete model
    internal struct Delete: Gloss.JSONDecodable {

        /// Event Id
        let event: String
        
        // MARK:
        // MARK: Initializers
        
        internal init?(json: JSON) {
            
            var eventId: String?
            
            if let eid: AnyObject = "event_id" <~~ json {
                if let str = eid as? String {
                    eventId = str
                } else if let num = eid as? NSNumber {
                    let intValue = num.int64Value
                    eventId = "\(intValue)"
                }
            }
            
            guard let id = eventId else { return nil }
            event = id
        }
    }

    // MARK:
    // MARK: Member Invite

    /// Member invite model
    internal struct MemberInvite: Gloss.JSONDecodable {

        // MARK:
        // MARK: User

        /// Member invite user model
        internal struct User: Gloss.JSONDecodable {

            /// Member Id
            internal let memberId: String

            /// User Id
            internal let userId: String

            /// Username/Email
            internal let username: String

            // MARK:
            // MARK: Audio

            /// User for calling purposes
            internal let earmuffed: Bool?

            /// User for calling purposes
            internal let muted: Bool?

            // MARK:
            // MARK: Initializers

            internal init?(json: JSON) {
                guard let memberId: String = "user.member_id" <~~ json else { return nil }
                guard let userId: String = "user.user_id" <~~ json else { return nil }
                guard let username: String = "user.name" <~~ json else { return nil }

                self.memberId = memberId
                self.userId = userId
                self.username = username
                self.earmuffed = "user.media.audio.earmuffed" <~~ json
                self.muted = "user.media.audio.muted" <~~ json
            }

            // MARK:
            // MARK: Helper

            /// Check if who got a audio call
            internal var hasMediaSupport: Bool {
                return earmuffed != nil && muted != nil
            }
        }

        /// Conversation Name
        internal let conversationName: String

        /// Invited by email
        internal let invitedBy: String

        /// Date
        internal let timestamp: Date

        /// User
        internal let user: User

        // MARK:
        // MARK: Initializers

        internal init?(json: JSON) {
            guard let conversationName: String = "cname" <~~ json else { return nil }
            guard let invitedBy: String = "invited_by" <~~ json else { return nil }
            guard let formatter = DateFormatter.ISO8601,
                let timestamp = Decoder.decode(dateForKey: "timestamp.invited", dateFormatter: formatter)(json) else {
                return nil
            }
            guard let user = User(json: json) else { return nil }

            self.conversationName = conversationName
            self.invitedBy = invitedBy
            self.timestamp = timestamp
            self.user = user
        }
    }
    
    /// Member left model
    internal struct MemberLeft: Gloss.JSONDecodable {

        // MARK:
        // MARK: User
        
        /// Member left user model
        internal struct User: Gloss.JSONDecodable {
        
            /// User Id
            internal let userId: String
            
            /// Username/Email
            internal let username: String
            
            // MARK:
            // MARK: Initializers
            
            internal init?(json: JSON) {
                guard let userId: String = "user.id" <~~ json else { return nil }
                guard let username: String = "user.name" <~~ json else { return nil }
                
                self.userId = userId
                self.username = username
            }
        }
        
        /// Date
        internal let timestamp: [MemberModel.State: Date]
        
        /// User
        internal let user: User
        
        // MARK:
        // MARK: Initializers
        
        internal init?(json: JSON) {
            guard let user = User(json: json) else { return nil }
            
            let ts = MemberModel.State.allValues.reduce([:]) { result, state -> [MemberModel.State: Date] in
                guard let formatter = DateFormatter.ISO8601, let date = Decoder.decode(dateForKey: "timestamp.\(state.rawValue)", dateFormatter: formatter)(json) else { return result }
                
                var result = result
                result[state] = date
                
                return result
            }

            guard ts.isEmpty == false else { return nil }
            
            self.timestamp = ts
            self.user = user
        }
    }
}
