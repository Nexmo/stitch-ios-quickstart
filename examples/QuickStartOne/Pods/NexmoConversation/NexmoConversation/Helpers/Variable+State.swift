//
//  Variable+State.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 17/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Media State
internal extension Variable where Variable.E == Media.State {

    // MARK:
    // MARK: Connect

    /// Is in .connecting or .connected state
    internal var isConnectState: Bool {
        return value == .connecting || value == .connected
    }
}
