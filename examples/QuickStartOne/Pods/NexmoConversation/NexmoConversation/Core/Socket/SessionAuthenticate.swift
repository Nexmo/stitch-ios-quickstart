//
//  SessionAuthenticate.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 27/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Authenticating
internal struct SessionAuthenticate {

    /// Device type
    internal let device: String = PushNotificationRouter.DeviceType.iOS.rawValue
    
    /// Device id
    internal let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    /// Auth token
    internal let token: String
    
    // MARK:
    // MARK: Initializers
    
    internal init(token: String) {
        self.token = token
    }
    
    // MARK:
    // MARK: JSON
    
    internal var json: [String: String] {
        return [
            "device_type": device,
            "device_id": deviceId,
            "token": token
        ]
    }
}
