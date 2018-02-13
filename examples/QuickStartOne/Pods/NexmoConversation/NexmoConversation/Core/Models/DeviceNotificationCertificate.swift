//
//  PushNotificationCertificate.swift
//  NexmoConversation
//
//  Created by shams ahmed on 16/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// APNS certificate model
public struct PushNotificationCertificate: Decodable {
    
    // MARK:
    // MARK: Keys
    
    private enum CodingKeys: String, CodingKey {
        case token
        case password
    }
    
    // MARK:
    // MARK: Properties
    
    /// Certificate
    public let certificate: String
    
    /// Password for certificate
    public let password: String?
    
    // MARK:
    // MARK: Initializers
    
    public init(from decoder: Decoder) throws {
        let allValues = try decoder.container(keyedBy: CodingKeys.self)
        
        certificate = try allValues.decode(String.self, forKey: .token)
        password = try? allValues.decode(String.self, forKey: .password)
    }
}
