//
//  EnumCollection.swift
//  NexmoConversation
//
//  Created by paul calver on 23/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//
// https://theswiftdev.com/2017/01/05/18-swift-gist-generic-allvalues-for-enums/

internal protocol EnumCollection: Hashable {
    static var allValues: [Self] { get }
}

internal extension EnumCollection {
    
    internal static var allValues: [Self] {
        return Array(self.cases())
    }
    
    // MARK:
    // MARK: Cases

    internal static func cases() -> AnySequence<Self> {
        typealias S = Self
        
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee } }
                
                guard current.hashValue == raw else { return nil }
                
                raw += 1
                
                return current
            }
        }
    }
}
