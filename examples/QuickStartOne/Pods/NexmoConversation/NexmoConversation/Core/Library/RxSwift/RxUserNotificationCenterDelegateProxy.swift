//
//  UNUserNotificationCenterDelegate+Rx.swift
//  NexmoConversation
//
//  Created by shams ahmed on 19/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UserNotifications

/// Proxy for UserNotificationCenterDelegateProxy
@available(iOS 10, *)
internal class RxUserNotificationCenterDelegateProxy: DelegateProxy<UNUserNotificationCenter, UNUserNotificationCenterDelegate>, DelegateProxyType, UNUserNotificationCenterDelegate {
    
    // MARK:
    // MARK: Initializers
    
    internal init(userNotification: UNUserNotificationCenter) {
        super.init(parentObject: userNotification, delegateProxy: RxUserNotificationCenterDelegateProxy.self)
    }
    
    // MARK:
    // MARK: DelegateProxy
    
    internal static func registerKnownImplementations() {
        self.register { RxUserNotificationCenterDelegateProxy(userNotification: $0) }
    }
    
    internal static func currentDelegate(for object: UNUserNotificationCenter) -> UNUserNotificationCenterDelegate? {
        return object.delegate
    }
    
    internal static func setCurrentDelegate(_ delegate: UNUserNotificationCenterDelegate?, to object: UNUserNotificationCenter) {
        object.delegate = delegate
    }
    
    // MARK:
    // MARK: DelegateProxyType
    
    override internal func setForwardToDelegate(_ forwardToDelegate: UNUserNotificationCenterDelegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: true)
    }
}
