//
//  RTCResponse.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Gloss

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

        internal func toJSON() -> JSON {
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
    internal struct Response: Gloss.JSONDecodable {

        /// RTC Id
        internal let id: String

        // MARK:
        // MARK: Initializers

        internal init?(json: JSON) {
            guard let rtcId: String = "rtc_id" <~~ json else { return nil }
            
            self.id = rtcId
        }
    }

    // MARK:
    // MARK: Answer

    /// Answer model from RTC new request
    internal struct Answer: Gloss.JSONDecodable {

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

        internal init?(json: JSON) {
            guard let answer: String = "body.answer" <~~ json else { return nil }
            guard let id: String = "body.rtc_id" <~~ json else { return nil }
            guard let conversationId: String = "cid" <~~ json else { return nil }

            guard let formatter = DateFormatter.ISO8601,
                let timestamp: Date = Decoder.decode(dateForKey: "timestamp", dateFormatter: formatter)(json) else {
                return nil
            }

            self.sdp = answer
            self.id = id
            self.conversationId = conversationId
            self.timestamp = timestamp
        }
    }
}
