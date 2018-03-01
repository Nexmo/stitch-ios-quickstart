//
//  UNUserNotificationCenterDelegate+Rx.swift
//  NexmoConversation
//
//  Created by shams ahmed on 19/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import UserNotifications

/// UNUserNotificationCenter
@available(iOS 10, *)
internal extension RxSwift.Reactive where Base: UNUserNotificationCenter {
    
    // MARK:
    // MARK: Private - Delegate
    
    /// UNUserNotificationCenterDelegate
    internal var delegate: DelegateProxy<UNUserNotificationCenter, UNUserNotificationCenterDelegate> {
        return RxUserNotificationCenterDelegateProxy.proxy(for: base)
    }
    
    // MARK:
    // MARK: Push Notification
    
    /// Remote notifications observable
    internal var receivedNotification: RxSwift.Observable<PushNotificationController.State> {
        let receiveNotification = delegate
            .methodInvoked(#selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:didReceive:withCompletionHandler:)))
            .map { value in PushNotificationController.State.receivedRemoteNotification(
                payload: self.formatNotificationPayload((value[1] as? UNNotificationResponse)?.notification.request.content.userInfo as? [String: Any]),
                fetchCompletion: value.last)
        }
        
        let willPresentNotification = delegate
            .methodInvoked(#selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:)))
            .map { value in PushNotificationController.State.receivedRemoteNotification(payload: self.formatNotificationPayload((value[1] as? UNNotification)?.request.content.userInfo as? [String: Any]), fetchCompletion: value.last)
        }

        return RxSwift.Observable.merge([receiveNotification, willPresentNotification])
    }

    // MARK:
    // MARK: Formatting

    private func formatNotificationPayload(_ payload: [String: Any]?) -> [String: Any] {
        // Look for Nexmo Conversation key
        guard var data = payload?[Constants.SDK.name] as? [String: Any] else { return [:] }
    
        if let aps = payload?["aps"] as? [String: Any], let type = aps["alert"] {
            data["type"] = type
        }
    
        return data
    }
}
