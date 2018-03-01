//
//  AppLifecycleController.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/10/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import UIKit
import RxSwift
import UserNotifications

/// Controller to handle common life cycle event while making there developer life easier i.e UIApplicationDelegate
public class AppLifecycleController: NSObject {

    // MARK:
    // MARK: Enum
    
    /// Notification
    ///
    /// - conversation: covnersation notification with reason
    /// - text: text event notification
    /// - image: image event notification
    public enum Notification: Equatable {
        /// covnersation notification with reason
        case conversation(ConversationCollection.T)
        /// text event notification
        case text(TextEvent)
        /// image event notification
        case image(ImageEvent)
    }
    
    // MARK:
    // MARK: Properties
    
    /// Controller to handle push notifications
    public let push: PushNotificationController
    
    /// Rx
    private let disposeBag = DisposeBag()
    
    // MARK:
    // MARK: Properties - Observable
    
    /// Events coming from push notification
    public var notifications: NexmoConversation.Observable<Notification> {
        return self.notificationVariable.asObservable().unwrap().share().wrap
    }

    /// Events coming from push notification variable
    internal let notificationVariable = RxSwift.Variable<Notification?>(nil)

    /// Received remote notifications observable
    public lazy var receiveRemoteNotification: NexmoConversation.Observable<PushNotificationController.RemoteNotification> = {
        var notifications = [RxSwift.Observable<PushNotificationController.State>]()

        if #available(iOS 10, *), !Environment.inTesting {
            notifications.append(UNUserNotificationCenter.current().rx.receivedNotification)
        }
        
        return RxSwift.Observable.merge(notifications)
            .map { state -> PushNotificationController.RemoteNotification in
                // we should be receiving a non empty dictionary
                guard case .receivedRemoteNotification(let payload, let completion) = state,
                    let data = payload as? [String: Any], !data.isEmpty else {
                        return PushNotificationController.RemoteNotification(payload: [:], fetchCompletion: nil)
                    }

                return PushNotificationController.RemoteNotification(payload: data, fetchCompletion: completion)
            }
            .share()
            .wrap
    }()
    
    /// Application state
    internal let applicationState: RxSwift.Observable<ApplicationState> = UIApplication.shared.rx.applicationState.share()

    // MARK:
    // MARK: Initializers

    internal init(networkController: NetworkController) {
        self.push = PushNotificationController(networkController: networkController)
        
        super.init()
        
        setup()
    }

    // MARK:
    // MARK: Private - Setup
    
    private func setup() {
        
    }
}

// MARK:
// MARK: Compare

/// Compare Notification reasons
/// :nodoc:
public func ==(lhs: AppLifecycleController.Notification, rhs: AppLifecycleController.Notification) -> Bool {
    switch (lhs, rhs) {
    case (.conversation(let l), .conversation(let r)):
        switch (l, r) {
        case (.inserted(let lConversation, _), .inserted(let rConversation, _)): return lConversation == rConversation
        case (.updated, .updated): return true
        case (.deleted, .deleted): return true
        case (.inserted, _): return false
        case (.updated, _): return false
        case (.deleted, _): return false
        }
    case (.text(let l), .text(let r)): return l == r
    case (.image(let l), .image(let r)): return l == r
    case (.conversation, _): return false
    case (.text, _): return false
    case (.image, _): return false
    }
}
