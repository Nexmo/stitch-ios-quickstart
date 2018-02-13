//
//  PushNotificationState.swift
//  NexmoConversation
//
//  Created by shams ahmed on 19/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation


public extension PushNotificationController {
    
    // MARK:
    // MARK: Typealias
    
    /// Payload from nexmo conversation
    public typealias RemoteNotification = (payload: [String: Any], fetchCompletion: Any?)
    
    // MARK:
    // MARK: Enum
    
    /// Push Notification State
    ///
    /// - none: none
    /// - unregistered
    /// - registeredWithDeviceToken: token
    /// - register failed with error
    /// - receivedRemoteNotification: payload
    public enum State: Equatable {
        case unknown
        case unregisteredForRemoteNotifications
        case registeredWithDeviceToken(Data)
        case registerForRemoteNotificationsFailed(Error)
        case receivedRemoteNotification(payload: [AnyHashable: Any]?, fetchCompletion: Any?) // ((UIBackgroundFetchResult) -> Void)
    }

}

/// Compare Push Notification States
///
/// - Parameters:
///   - lhs: PushNotificationState
///   - rhs: PushNotificationState
/// - Returns: result
/// :nodoc:
public func ==(lhs: PushNotificationController.State, rhs: PushNotificationController.State) -> Bool {
    switch (lhs, rhs) {
    case (.unknown, .unknown): return true
    case (.unregisteredForRemoteNotifications, .unregisteredForRemoteNotifications): return true
    case (.registeredWithDeviceToken(_), .registeredWithDeviceToken(_)): return true
    case (.registerForRemoteNotificationsFailed(_), .registerForRemoteNotificationsFailed(_)): return true
    case (.receivedRemoteNotification(_, _), .receivedRemoteNotification(_, _)): return true
    case (.unknown, _),
         (.unregisteredForRemoteNotifications, _),
         (.registeredWithDeviceToken, _),
         (.registerForRemoteNotificationsFailed, _),
         (.receivedRemoteNotification, _): return false
    }
}
