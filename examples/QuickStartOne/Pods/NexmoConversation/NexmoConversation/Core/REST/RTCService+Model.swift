//
//  RTCService+Model.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 27/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Gloss

// Request models
internal extension RTCService {

    // MARK:
    // MARK: New

    /// Requesting new RTC call
    internal struct New: Gloss.JSONEncodable {

        /// Session iD
        let id: String
        
        /// Member Id
        let from: String

        /// SDP media
        let sdp: String

        /// label
        let label: String

        // MARK:
        // MARK: Initializers

        internal init(from: String, sdp: String, label: String="", id: String) {
            self.from = from
            self.sdp = sdp
            self.label = label
            self.id = id
        }

        // MARK:
        // MARK: JSON

        internal func toJSON() -> JSON? {
            return [
                "from": from,
                "body": [
                    "offer": [
                        "sdp": sdp,
                        "label": label
                    ]
                ],
                "originating_session": id
            ]
        }
    }
}
