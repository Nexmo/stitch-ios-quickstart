//
//  Substring.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 28/12/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Comparing in Switch statement support
internal struct Substring {
    
    fileprivate let string: String
    
    // MARK:
    // MARK: Initializers
    
    internal init(_ substr: String) {
        self.string = substr
    }
}

internal func ~=(substr: Substring, str: String) -> Bool {
    return str.range(of: substr.string) != nil
}
