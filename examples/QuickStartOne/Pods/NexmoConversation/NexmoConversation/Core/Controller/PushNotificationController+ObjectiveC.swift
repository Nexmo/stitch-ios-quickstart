//
//  PushNotificationController+ObjectiveC.swift
//  NexmoConversation
//
//  Created by paul calver on 17/11/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

public extension PushNotificationController {
    
    // MARK:
    // MARK: User (Objective-C compatibility support)
    
    /// Add device token
    ///
    /// - Parameters:
    ///   - deviceToken: token
    ///   - deviceId: unique device id i.e UIDevice.currentDevice.identifierForVendor?.uuidString or a custom id
    ///   - onSuccess: true if success
    ///   - onFailure: error
    @objc
    public func update(deviceToken: Data, deviceId: String?, _ onSuccess: @escaping (Bool) -> Void, onFailure: ((Error) -> Void)?) {
        update(deviceToken: deviceToken, deviceId: deviceId).subscribe(
            onSuccess: onSuccess,
            onError: onFailure
        )
    }
    
    /// Remove device token with your given device iD
    ///
    /// - Parameters:
    ///   - uuid: unique device id i.e UIDevice.currentDevice.identifierForVendor?.uuidString or a custom id
    ///   - onSuccess: true if success
    ///   - onFailure: error
    @objc
    public func removeDeviceToken(deviceId: String?, _ onSuccess: @escaping (Bool) -> Void, onFailure: ((Error) -> Void)?) {
        removeDeviceToken(deviceId: deviceId).subscribe(
            onSuccess: onSuccess,
            onError: onFailure
        )
    }
}
