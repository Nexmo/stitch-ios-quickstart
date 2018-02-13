//
//  EventState.swift
//  NexmoConversation
//
//  Created by James Green on 21/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// State of a event i.e sms, text, image 
internal struct EventState: Decodable {
    
    // MARK:
    // MARK: Keys
    
    private enum CodingKeys: String, CodingKey {
        case state
    }
    
    private enum StateCodingKeys: String, CodingKey {
        case delivered = "delivered_to"
        case seen = "seen_by"
        case done = "play_done"
    }
    
    // MARK:
    // MARK: Properties
    
    internal let deliveredTo: [String: String]
    
    internal let seenBy: [String: String]
    
    internal let playDone: Bool?
    
    // MARK:
    // MARK: Initializers
    
    internal init(from decoder: Decoder) throws {
        let allValues = try { () -> KeyedDecodingContainer<StateCodingKeys> in
            guard let values = try? decoder.container(keyedBy: CodingKeys.self), values.contains(.state) else {
                return try decoder.container(keyedBy: StateCodingKeys.self)
            }
            
            return try values.nestedContainer(keyedBy: StateCodingKeys.self, forKey: .state)
        }()
        
        deliveredTo = (try? allValues.decode([String: String].self, forKey: .delivered)) ?? [:]
        seenBy = (try? allValues.decode([String: String].self, forKey: .seen)) ?? [:]
        playDone = try allValues.decodeIfPresent(Bool.self, forKey: .done)
    }
}
