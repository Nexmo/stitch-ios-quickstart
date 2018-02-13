//
//  Configuration.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 25/05/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Check if log level is higher then xyz..
///
/// - Parameters:
///   - lhs: log level
///   - rhs: log level
/// - Returns: result
internal func >=(lhs: Configuration.LogLevel, rhs: Configuration.LogLevel) -> Bool {
    switch (lhs, rhs) {
    case (.error, .error): return true
    case (.warning, .warning): return true
    case (.warning, .error): return true
    case (.info, .info): return true
    case (.none, .none): return true
    default: return false
    }
}

/// Client configuration
public struct Configuration {

    // MARK:
    // MARK: Enum

    /// Log level
    ///
    /// - none: Silent all logs from SDK
    /// - info: Output logs for information, warning and errors
    /// - `warning`: Output logs for warning and errors
    /// - error: Output logs for only errors
    public enum LogLevel {
        case none
        case info
        case warning
        case error
    }

    // MARK:
    // MARK: Default

    /// Global client configuration
    public static let `default`: Configuration = Configuration()

    // MARK:
    // MARK: Configurations

    /// Log level for console logs, @Default to: .warning
    public let logLevel: LogLevel

    /// Auto reconnect when network disconnects, @Default to: true
    public let autoReconnect: Bool

    /// Remove all assets, files, cache and database, @Default to: false
    public let clearAllData: Bool

    /// Enable support for push notifications, @Default to: true
    public let pushNotifications: Bool
    
    // MARK:
    // MARK: Initializers
    
    /// Create configuration
    public init(with logLevel: LogLevel = .warning, autoReconnect: Bool = true, clearAllData: Bool = false, pushNotifications: Bool = true) {
        self.logLevel = logLevel
        self.autoReconnect = autoReconnect
        self.clearAllData = clearAllData
        self.pushNotifications = pushNotifications
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    /// Setup client before starting all services 
    private func setup() {
        try? FileManager.default.createDirectory(atPath: Constants.SDK.documentPath, withIntermediateDirectories: true)
    }
}
