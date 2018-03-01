//
//  Media+ObjectiveC.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 20/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Objective-C compatibility
public extension Media {

    // MARK:
    // MARK: Typealias

    /// Objective-C completion block
    public typealias Completion = ((State) -> Void)

    // MARK:
    // MARK: State (Objective-C compatibility support)

    /// Objective-C: Observe audio states
    ///
    /// - Parameter completion: completion block
    public func stateObjc(_ completion: @escaping Completion) {
        state.subscribe(onSuccess: { completion($0) })
    }

    // MARK:
    // MARK: Media (Objective-C compatibility support)

    /// Objective-C: Enable audio
    ///
    /// - Parameter completion: state of audio
    /// - Returns: errors from setting up audio
    public func enable(_ completion: @escaping Completion) -> Errors? {
        stateObjc(completion)

        do {
            try enable()
        } catch let error {
            return error as? Errors
        }

        return nil
    }
}
