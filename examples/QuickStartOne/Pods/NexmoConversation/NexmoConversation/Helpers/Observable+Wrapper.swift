//
//  ObservableType+Wrapper.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 15/02/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Helper to move from exposing rx functions to help devs
internal extension RxSwift.Observable {
    
    // MARK:
    // MARK: Wrapper

    /// Convert RxSwift.Observable to NexmoConversation.Observable
    internal var wrap: NexmoConversation.Observable<E> {
        return NexmoConversation.Observable<E>(self)
    }
}

// MARK: - Helper to move from exposing rx functions to help devs
internal extension RxSwift.Variable {
    
    // MARK:
    // MARK: Wrapper
    
    /// Convert RxSwift.Observable to NexmoConversation.Observable
    internal var wrap: NexmoConversation.MutableObservable<E> {
        return NexmoConversation.MutableObservable<E>(self)
    }
}
