//
//  UserModel.swift
//  NexmoConversation
//
//  Created by James Green on 01/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// User model
internal class UserModel: Decodable {
    
    // MARK:
    // MARK: Keys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case displayName = "display_name"
        case image = "image_url"
    }
    
    // MARK:
    // MARK: Properties
    
    /// ID of the corresponding User
    internal var uuid: String
    
    /// The unique name for this User
    internal var name: String

    /// Display Name
    internal var displayName: String
    
    /// Avatar
    internal var imageUrl: String
    
    /// Channel for account actions
    internal var channels: AnyObject?
    
    // MARK:
    // MARK: Initializers

    internal init(displayName: String, imageUrl: String, uuid: String, name: String) {
        self.displayName = displayName
        self.imageUrl = imageUrl
        self.uuid = uuid
        self.name = name
    }
    
    internal required init(from decoder: Decoder) throws {
        let allValues = try decoder.container(keyedBy: CodingKeys.self)
        
        uuid = try allValues.decode(String.self, forKey: .id)
        name = try allValues.decode(String.self, forKey: .name)
        displayName = (try allValues.decodeIfPresent(String.self, forKey: .displayName)) ?? ""
        imageUrl = (try allValues.decodeIfPresent(String.self, forKey: .image)) ?? ""
    }
}
