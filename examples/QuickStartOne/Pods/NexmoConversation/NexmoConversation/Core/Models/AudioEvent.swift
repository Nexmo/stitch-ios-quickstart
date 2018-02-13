//
//  AudioEvent.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 29/11/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Audio Event
@objc(NXMAudioEvent)
public class AudioEvent: EventBase {
    
    // MARK:
    // MARK: Properties
    
    /// Audio enabled
    public internal(set) lazy var enabled: Bool = {
        guard let audio: Event.Body.Audio = self.data.rest.model() else { return false }
        
        return audio.enabled
    }()
}
