//
//  Bool+String.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 27/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

internal extension Bool {

    // MARK:
    // MARK: Initializers

    /// Convert String value to Bool
    internal init?(string: String?) {
        guard let string = string?.lowercased() else { return nil }
        
        switch string {
        case "true", "yes", "1": self = true
        case "false", "no", "0": self = false
        default: return nil
        }
    }
}
