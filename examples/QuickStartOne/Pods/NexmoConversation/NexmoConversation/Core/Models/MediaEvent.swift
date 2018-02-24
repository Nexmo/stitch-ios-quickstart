//
//  MediaEvent.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 29/11/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Media Event
@objc(NXMMediaEvent)
public class MediaEvent: EventBase {
    
    // MARK:
    // MARK: Properties
    
    /// Media enabled
    public internal(set) lazy var enabled: Bool = {
        guard let audio: Event.Body.Audio = try? self.data.rest.model() else { return false }
        
        return audio.enabled
    }()
}
