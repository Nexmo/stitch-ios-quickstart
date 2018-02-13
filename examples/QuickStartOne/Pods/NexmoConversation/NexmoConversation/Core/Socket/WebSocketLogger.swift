//
//  WebSocketLogger.swift
//  NexmoConversation
//
//  Created by shams ahmed on 09/03/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import SocketIO

/// Web socket logger
internal class WebSocketLogger: SocketLogger {
    
    /// Enable/disable logs
    internal var log: Bool = true
    
    // MARK:
    // MARK: Logging
    
    func log(_ message: @autoclosure () -> String, type: String) {
        let message = message()
        
        log(message)
    }
    
    /// Default implementation.
    func error(_ message: @autoclosure () -> String, type: String) {
        let message = message()
        
        log(message)
    }
    
    /// Verbose log
    internal func log(_ message: String) {
        switch message {
        case "Adding engine": return
        case Substring("Starting engine"): return
        case "Handshaking": return
        case Substring("Sending ws"): return
        case Substring("Should parse message"): return
        case Substring("Joining namespace"): return
        case Substring("Adding handler for event"): return
        case Substring("Handling event: statusChange with data"): return
        case Substring("Handling event: ping with data"): return
        case Substring("Handling event: pong with data"): return
        case Substring("Emitting"): return
        case "Engine opened Connect": return
        case Substring("Writing ws"): return
        case "Engine is being closed.": return
        case "Tried connecting socket when engine isn\'t open. Connecting": return
        case Substring("Got message"): return
        case Substring("Writing ws"): return
        case Substring("Parsing"): return
        case Substring("Decoded packet as"): return
            case Substring("Handling event: error with data"): return
        case Substring("Handling event: connect with data"): return
        case Substring("Handling event: disconnect with data"): return
        case Substring("Handling event: text:typing:off with data"): return
        case Substring("Handling event: text:typing:on with data"):
            printLog("Handling event: text:typing:on")
        case Substring("Handling event: text:delivered with data"): return
        case Substring("Handling event: text:seen with data"):
            printLog("Handling event: text:seen")
        case Substring("Handling event: image:delivered with data"): return
        case Substring("Handling event: image:seen with data"):
            printLog("Handling event: image:seen")
        case Substring("Handling event: rtc:answer with data"):
            printLog("Handling event: rtc:answer")
        case Substring("Handling event: reconnet with data"): return
        case Substring("Handling event: reconnetAttempt with data"): return
        case "session:success": return
        case "Closing socket": return
        case "Disconnected": return
        case "Connect": return
        case "Trying to reconnect": return
        case "Disconnected: Namespace leave": return
        case "output stream error during write": return
        case Substring("Unknown event"): return
        default:
            printLog(message)
        }
    }
    
    /// Error log
    internal func error(_ message: String) {
         printLog(message)
    }
    
    // MARK:
    // MARK: Print
    
    /// Print log
    ///
    /// - Parameters:
    ///   - message: text
    ///   - args: extra argments
    private func printLog(_ message: String) {
        guard log else { return }
        
        Log.info(.socketIO, message)
    }
}
