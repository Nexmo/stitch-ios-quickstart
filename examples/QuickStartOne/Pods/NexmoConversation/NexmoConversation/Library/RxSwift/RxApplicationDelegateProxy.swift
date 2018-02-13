//
//  RxApplicationDelegateProxy.swift
//  NexmoConversation
//
//  Created by shams ahmed on 24/10/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Helper to proxy UIApplicationDelegate to SDK
internal class RxApplicationDelegateProxy: DelegateProxy<UIApplication, UIApplicationDelegate>, DelegateProxyType, UIApplicationDelegate {
    
    // Typed parent object.
    private weak private(set) var application: UIApplication?
    
    // MARK:
    // MARK: Initializers
    
    internal init(application: ParentObject) {
        self.application = application
        
        super.init(parentObject: application, delegateProxy: RxApplicationDelegateProxy.self)
    }
    
    // MARK:
    // MARK: DelegateProxy
    
    internal static func registerKnownImplementations() {
        self.register { RxApplicationDelegateProxy(application: $0) }
    }
    
    internal static func currentDelegate(for object: UIApplication) -> UIApplicationDelegate? {
        return object.delegate
    }
    
    internal static func setCurrentDelegate(_ delegate: UIApplicationDelegate?, to object: UIApplication) {
        object.delegate = delegate
    }
    
    // MARK:
    // MARK: DelegateProxyType
    
    override internal func setForwardToDelegate(_ forwardToDelegate: UIApplicationDelegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: true)
    }
}
