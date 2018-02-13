//
//  SocketConfiguration.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import SocketIO

/// Socket IO Configuration
internal struct SocketConfiguration {

    // MARK:
    // MARK: Static

    /// Configurations
    internal static func withLogging(_ isLogEnabled: Bool) -> SocketIOClientConfiguration {
        return [
            .forceWebsockets(true),
            .log(isLogEnabled),
            .path("/rtc/"),
            .reconnects(true),
            .reconnectAttempts(-1),
            .reconnectWait(Int(arc4random_uniform(45)) + 15),
            .logger(WebSocketLogger())
            //.secure(true)
            // TODO: Check for secure connections
        ]
    }
}
