//
//  Event+Media.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 08/11/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// RTC body
internal extension Event.Body {

    // MARK:
    // MARK: Audio

    /// Audio
    internal struct Audio: Decodable {
        
        // MARK:
        // MARK: Keys
        
        private enum Codingkeys: String, CodingKey {
            case audio
        }
        
        // MARK:
        // MARK: Properties
        
        /// Member audio state
        let enabled: Bool
        
        // MARK:
        // MARK: Initializers
        
        internal init(from decoder: Decoder) throws {
            enabled = try decoder.container(keyedBy: Codingkeys.self).decode(Bool.self, forKey: .audio)
        }
    }
    
    // MARK:
    // MARK: Mute
    
    /// Sound
    internal struct Mute: Decodable {
        
        // MARK:
        // MARK: Keys
        
        private enum Codingkeys: String, CodingKey {
            case mute
        }
        
        // MARK:
        // MARK: Properties
        
        /// ???
        let enabled: Bool
        
        // MARK:
        // MARK: Initializers
        
        internal init(from decoder: Decoder) throws {
            fatalError()
        }
    }
}
