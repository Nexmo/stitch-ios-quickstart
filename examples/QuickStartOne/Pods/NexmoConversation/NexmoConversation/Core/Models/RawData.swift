//
//  RawData.swift
//  NexmoConversation
//
//  Created by shams ahmed on 25/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Model to box a type 
internal struct RawData: RawDecodable {
    
    /// Raw data
    internal let value: Data
    
    // MARK:
    // MARK: Initializers
    
    internal init?(_ data: Data) {
        value = data
    }
}
