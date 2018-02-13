//
//  Event+Media.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 08/11/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Gloss

/// RTC body
internal extension Event.Body {

    // MARK:
    // MARK: Audio

    /// Audio
    internal struct Audio: Gloss.JSONDecodable {
        
        /// Member audio state
        let enabled: Bool
        
        // MARK:
        // MARK: Initializers
        
        internal init?(json: JSON) {
            guard let state: Bool = "audio" <~~ json else { return nil }
            
            enabled = state
        }
    }
    
    // MARK:
    // MARK: Mute
    
    /// Sound
    internal struct Mute: Gloss.JSONDecodable {
        
        /// ???
        let enabled: Bool
        
        // MARK:
        // MARK: Initializers
        
        internal init?(json: JSON) {
            guard let state: Bool = "???" <~~ json else { return nil }
            
            enabled = state
        }
    }
}
