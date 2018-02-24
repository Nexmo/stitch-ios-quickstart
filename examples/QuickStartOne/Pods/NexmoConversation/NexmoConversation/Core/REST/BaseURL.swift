//
//  BaseURL.swift
//  NexmoConversation
//
//  Created by James Green on 23/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Base URL for our services
internal struct BaseURL {
    
    // MARK:
    // MARK: Enum
    
    /// Configurable environment paths for testing only
    private enum Path: String {
        case socket = "socket_url"
        case rest = "rest_url"
        case ips = "ips_url"
        case stun = "stun_url"
    }
    
    /// Testing only
    internal static var inDevelopmentMode = false
    
    // MARK:
    // MARK: Base URL
    
    /// WebSocket Service
    internal static var socket: String = {
        guard inDevelopmentMode, let url = ProcessInfo.processInfo.environment[Path.socket.rawValue],
            !url.isEmpty else {
            return "https://ws.nexmo.com"
        }
        
        // Configurable for testing only, see readme file
        return url
    }()
    
    /// REST Service
    internal static var rest: String = {
        guard inDevelopmentMode, let url = ProcessInfo.processInfo.environment[Path.rest.rawValue],
            !url.isEmpty else {
            return "https://api.nexmo.com/beta"
        }
        
        // Configurable for testing only, see readme file
        return url
    }()
    
    /// Image Processing Service
    internal static var ips: String = {
        guard inDevelopmentMode, let url = ProcessInfo.processInfo.environment[Path.ips.rawValue],
            !url.isEmpty else {
            return "https://api.nexmo.com/v1"
        }
        
        // Configurable for testing only, see readme file
        return url
    }()
    
    /// Stun Service
    internal static var stun: String = {
        guard inDevelopmentMode, let url = ProcessInfo.processInfo.environment[Path.stun.rawValue],
            !url.isEmpty else {
            // TODO: add with prod
            return ""
        }
        
        return url
    }()
}
