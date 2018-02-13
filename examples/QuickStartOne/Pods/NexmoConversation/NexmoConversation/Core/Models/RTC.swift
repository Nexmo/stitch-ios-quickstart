//
//  RTCResponse.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// RTC Namespace
internal enum RTC {

}

/// RTC Requests
internal extension RTC {

    // MARK:
    // MARK: Requests

    /// Request model from RTC
    internal struct Request {

        /// RTC Id
        internal let id: String

        /// Conversation Id
        internal let conversationId: String

        /// To member
        internal let to: String

        /// Event type
        internal let type: Event.EventType

        // MARK:
        // MARK: JSON

        internal var json: [String: Any] {
            return [
                "cid": conversationId,
                "to": to,
                "call_id": id,
                "type": type.rawValue,
                "body": []
            ]
        }
    }
}

/// RTC Respones
internal extension RTC {

    // MARK:
    // MARK: Response

    /// Response model from RTC request
    internal struct Response: Decodable {

        // MARK:
        // MARK: Keys
        
        private enum CodingKeys: String, CodingKey {
            case id = "rtc_id"
        }
        
        // MARK:
        // MARK: Properties
        
        /// RTC Id
        internal let id: String

        // MARK:
        // MARK: Initializers

        internal init(from decoder: Decoder) throws {
            id = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .id)
        }
    }

    // MARK:
    // MARK: Answer

    /// Answer model from RTC new request
    internal struct Answer: Decodable {

        // MARK:
        // MARK: Keys
        
        private enum CodingKeys: String, CodingKey {
            case cid
            case body
            case timestamp
        }
        
        private enum BodyCodingKeys: String, CodingKey {
            case id = "rtc_id"
            case answer
        }
        
        // MARK:
        // MARK: Properties
        
        /// SDP
        internal let sdp: String

        /// RTC Id
        internal let id: String

        /// Conversation Id
        internal let conversationId: String

        /// Timestamp
        internal let timestamp: Date

        // MARK:
        // MARK: Initializers

        internal init(from decoder: Decoder) throws {
            let allValues = try decoder.container(keyedBy: CodingKeys.self)
            let nestedContainer = try allValues.nestedContainer(keyedBy: BodyCodingKeys.self, forKey: .body)
            
            conversationId = try allValues.decode(String.self, forKey: .cid)
            sdp = try nestedContainer.decode(String.self, forKey: .answer)
            id = try nestedContainer.decode(String.self, forKey: .id)
            timestamp = try allValues.decode(Date.self, forKey: .timestamp)
        }
    }
}
