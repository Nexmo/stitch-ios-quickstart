//
//  OptionalType.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/02/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation

/// OptionalType
internal extension Sequence where Iterator.Element: OptionalType {
    
    // MARK:
    // MARK: Filter nil's
    
    /// Filter out nil object in a sequence. @Warning remove in Swift 5 as they have this method by than
    internal func compactMap() -> [Iterator.Element.Wrapped] {
        return flatMap { $0.value }
    }
}
