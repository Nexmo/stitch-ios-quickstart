//
//  Array+Helper.swift
//  NexmoConversation
//
//  Created by paul calver on 23/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//
// https://swiftdailies.github.io/safe-array-indexing/

internal extension Array {
    
    // MARK:
    // MARK: Subscript

    internal subscript (safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}
