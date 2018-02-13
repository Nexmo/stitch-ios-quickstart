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
    // MARK: Properties

    /// Controller to handle push notifications
    public let push: PushNotificationController
    
    /// Events coming from push notification
    public var notifications: Observable<Notification> { return self.notificationVariable.asObservable().unwrap().share() }

    /// Events coming from push notification variable
    internal let notificationVariable = Variable<Notification?>(nil)

    /// Received remote notifications observable
    public lazy var receiveRemoteNotification: Observable<PushNotificationController.RemoteNotification> = {
        var notifications = [Observable<PushNotificationController.State>]()

        if #available(iOS 10, *), !Environment.inTesting {
            notifications.append(UNUserNotificationCenter.current().rx.receivedNotification)
        }
        
        return Observable.merge(notifications)
            .map { state -> PushNotificationController.RemoteNotification in
                guard case .receivedRemoteNotification(let payload, let completion) = state,
                    // we should be receiving a non empty dictionary
                    let data = payload as? [String: Any], !data.isEmpty else {
                        return PushNotificationController.RemoteNotification(payload: [:], fetchCompletion: nil)
                }

                return PushNotificationController.RemoteNotification(payload: data, fetchCompletion: completion)
            }
            .share()
    }()
    
    /// Application state
    internal let applicationState: Observable<ApplicationState> = UIApplication.shared.rx.applicationState.share()

    /// Rx
    private let disposeBag = DisposeBag()

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
