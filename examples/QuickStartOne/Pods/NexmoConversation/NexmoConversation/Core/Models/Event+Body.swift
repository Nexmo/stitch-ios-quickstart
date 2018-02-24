//
//  Body+Text.swift
//  NexmoConversation
//
//  Created by shams ahmed on 22/06/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Body models
internal extension Event.Body {
    
    // MARK:
    // MARK: Text
    
    /// Text model
    internal struct Text: Decodable {
        
        // MARK:
        // MARK: Enum
        
        private enum CodingKeys: String, CodingKey {
            case text
        }
        
        // MARK:
        // MARK: Properties
        
        /// Text
        internal let text: String
        
        // MARK:
        // MARK: Initializers

        internal init(from decoder: Decoder) throws {
            text = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .text)
        }
    }
    
    // MARK:
    // MARK: Delete
    
    /// Delete model
    internal struct Delete: Decodable {

        // MARK:
        // MARK: Enum
        
        private enum CodingKeys: String, CodingKey {
            case eventId = "event_id"
        }
        
        // MARK:
        // MARK: Properties
        
        /// Event Id
        let event: String
        
        // MARK:
        // MARK: Initializers
        
        internal init(from decoder: Decoder) throws {
            let allValues = try decoder.container(keyedBy: CodingKeys.self)
            
            guard let id = try? allValues.decode(String.self, forKey: .eventId) else {
                let id = try allValues.decode(Int.self, forKey: .eventId)
                
                event = "\(id)"
                
                return
            }
            
            event = id
        }
    }

    // MARK:
    // MARK: Member Invite

    /// Member invite model
    internal struct MemberInvite: Decodable {

        // MARK:
        // MARK: User

        /// Member invite user model
        internal struct User: Decodable {

            // MARK:
            // MARK: Enum
            
            private enum CodingKeys: String, CodingKey {
                internal enum User: String, CodingKey {
                    internal enum Audio: String, CodingKey {
                        internal enum Sound: String, CodingKey {
                            case earmuffed
                            case muted
                        }
                        
                        case audio
                    }
                    
                    case id = "user_id"
                    case memberId = "member_id"
                    case name = "name"
                    case media
                }
                
                case user
            }
            
            // MARK:
            // MARK: Properties
            
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

            internal init(from decoder: Decoder) throws {
                let allValues = try { () -> KeyedDecodingContainer<CodingKeys.User> in
                    guard let values = try? decoder.container(keyedBy: CodingKeys.self), values.contains(.user) else {
                        return try decoder.container(keyedBy: CodingKeys.User.self)
                    }
                    
                    return try values.nestedContainer(keyedBy: CodingKeys.User.self, forKey: .user)
                }()
                
                let media = try allValues.nestedContainer(keyedBy: CodingKeys.User.Audio.self, forKey: .media)
                let audio = try? media.nestedContainer(keyedBy: CodingKeys.User.Audio.Sound.self, forKey: .audio)
                
                memberId = try allValues.decode(String.self, forKey: .memberId)
                userId = try allValues.decode(String.self, forKey: .id)
                username = try allValues.decode(String.self, forKey: .name)
                earmuffed = try audio?.decodeIfPresent(Bool.self, forKey: .earmuffed)
                muted = try audio?.decodeIfPresent(Bool.self, forKey: .muted)
            }

            // MARK:
            // MARK: Helper

            /// Check if who got a audio call
            internal var hasMediaSupport: Bool {
                return earmuffed != nil && muted != nil
            }
        }
        
        // MARK:
        // MARK: Enum
        
        private enum CodingKeys: String, CodingKey {
            case cname
            case invitedBy = "invited_by"
            case timestamp
            case user
        }
        
        // MARK:
        // MARK: Properties

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

        internal init(from decoder: Decoder) throws {
            let allValues = try decoder.container(keyedBy: CodingKeys.self)
            
            conversationName = try allValues.decode(String.self, forKey: .cname)
            invitedBy = try allValues.decode(String.self, forKey: .invitedBy)
            user = try allValues.decode(User.self, forKey: .user)
            
            guard let invited = (try allValues.decode([String: String].self, forKey: .timestamp))["invited"],
                let date = DateFormatter.ISO8601?.date(from: invited) else {
                throw JSONError.malformedJSON
            }
            
            timestamp = date
        }
    }
    
    /// Member left model
    internal struct MemberLeft: Decodable {

        // MARK:
        // MARK: User
        
        /// Member left user model
        internal struct User: Decodable {
        
            // MARK:
            // MARK: Enum
            
            private enum CodingKeys: String, CodingKey {
                internal enum User: String, CodingKey {
                    case id
                    case name
                }
                
                case user
            }
            
            // MARK:
            // MARK: Properties
            
            /// User Id
            internal let userId: String
            
            /// Username/Email
            internal let username: String
            
            // MARK:
            // MARK: Initializers
            
            internal init(from decoder: Decoder) throws {
                let allValues = try { () -> KeyedDecodingContainer<CodingKeys.User> in
                    guard let values = try? decoder.container(keyedBy: CodingKeys.self), values.contains(.user) else {
                        return try decoder.container(keyedBy: CodingKeys.User.self)
                    }
                    
                    return try values.nestedContainer(keyedBy: CodingKeys.User.self, forKey: .user)
                }()
                
                userId = try allValues.decode(String.self, forKey: .id)
                username = try allValues.decode(String.self, forKey: .name)
            }
        }
        
        // MARK:
        // MARK: Enum
        
        private enum CodingKeys: String, CodingKey {
            case user
            case timestamp
        }
        
        // MARK:
        // MARK: Properties
        
        /// Date
        internal let timestamp: [MemberModel.State: Date]
        
        /// User
        internal let user: User
        
        // MARK:
        // MARK: Initializers
        
        internal init(from decoder: Decoder) throws {
            let allValues = try decoder.container(keyedBy: CodingKeys.self)
            let allStates = try allValues.decode([String: String].self, forKey: .timestamp)
            let timestamps = allStates.reduce([:]) { result, states -> [MemberModel.State: Date] in
                guard let state = MemberModel.State(rawValue: states.key.lowercased()),
                    let date = DateFormatter.ISO8601?.date(from: states.value) else {
                    return result
                }
                
                var result = result
                result[state] = date
                
                return result
            }
            
            guard !timestamps.isEmpty else { throw JSONError.malformedJSON }
            
            user = try allValues.decode(User.self, forKey: .user)
            timestamp = timestamps
        }
    }
    
    // MARK:
    // MARK: Deleted
    
    /// Deleted model
    internal struct Deleted: Decodable {
        
        // MARK:
        // MARK: Enum
        
        private enum CodingKeys: String, CodingKey {
            internal enum Deleted: String, CodingKey {
                case deleted
            }
            
            case timestamp
        }
        
        // MARK:
        // MARK: Properties
        
        /// Timestamp of when event was deleted
        internal let timestamp: Date
        
        // MARK:
        // MARK: Initializers
        
        internal init(with date: Date) {
            timestamp = date
        }
        
        internal init(from decoder: Decoder) throws {
            let allValues = try decoder.container(keyedBy: CodingKeys.self)
            let dates = try allValues.decode([String: String].self, forKey: .timestamp)
            
            guard let rawDate = dates[CodingKeys.Deleted.deleted.rawValue],
                let date = DateFormatter.ISO8601?.date(from: rawDate) else {
                throw JSONError.malformedJSON
            }
            
            timestamp = date
        }
        
        // MARK:
        // MARK: JSON
        
        internal var json: [String: Any]? {
            guard let date = DateFormatter.ISO8601?.string(from: timestamp) else { return nil }
            
            return [
                CodingKeys.timestamp.rawValue: [CodingKeys.Deleted.deleted.rawValue: date]
            ]
        }
    }
}
