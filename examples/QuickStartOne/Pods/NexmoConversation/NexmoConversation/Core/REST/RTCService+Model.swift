//
//  RTCService+Model.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 27/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Request models
internal extension RTCService {

    // MARK:
    // MARK: New

    /// Requesting new RTC call
    internal struct New {

        /// Session iD
        internal let id: String
        
        /// Member Id
        internal let from: String

        /// SDP media
        internal let sdp: String

        /// label
        internal let label: String

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
        
        internal var json: [String: Any]? {
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
