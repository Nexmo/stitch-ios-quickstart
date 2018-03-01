//
//  PushNotificationController.swift
//  NexmoConversation
//
//  Created by Paul Calver on 16/11/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift
import UserNotifications

/// Push notification controller handles configuration of push notifications and handles push notification state
@objc(NXMPushNotificationController)
public class PushNotificationController: NSObject {
    
    // MARK:
    // MARK: Typealias
    
    /// Payload from nexmo conversation
    public typealias RemoteNotification = (payload: [String: Any], fetchCompletion: Any?)
    
    // MARK:
    // MARK: Enum
    
    /// Push Notification State
    ///
    /// - unknown: unknown push notification state
    /// - unregisteredForRemoteNotifications: unregistered for remote notification
    /// - registeredWithDeviceToken: registered for notification
    /// - registerForRemoteNotificationsFailed: registered for notification failed with error
    /// - receivedRemoteNotification: received remote notification
    public enum State: Equatable {
        /// unknown push notification state
        case unknown
        /// unregistered for remote notification
        case unregisteredForRemoteNotifications
        /// registered for notification
        case registeredWithDeviceToken(Data)
        /// registered for notification failed with error
        case registerForRemoteNotificationsFailed(Error)
        /// received remote notification
        case receivedRemoteNotification(payload: [AnyHashable: Any]?, fetchCompletion: Any?)
    }
    
    // MARK:
    // MARK: Properties - Observable
    
    /// Push notification state
    internal var subject = RxSwift.Variable<PushNotificationController.State?>(nil)
    
    /// Push notification state observable
    public var state: NexmoConversation.Observable<PushNotificationController.State> {
        return subject.asObservable().unwrap().share().wrap
    }
    
    // MARK:
    // MARK: Properties
    
    /// Network controller
    private let networkController: NetworkController
    
    /// Rx
    internal let disposeBag = DisposeBag()
    
    // MARK:
    // MARK: Initializers
    
    internal init(networkController: NetworkController) {
        self.networkController = networkController
        
        super.init()
    }
    
    // MARK:
    // MARK: Request Push Notification Permission
    
    /// Request permission
    public func requestPermission() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] settings in
                if settings.authorizationStatus == .denied {
                    // if user has denied push notifications inform observers
                    self?.unregisteredForRemoteNotifications()
                } else {
                    // register for push notifications
                    self?.registerForPushNotifications()
                }
            })
        } else {
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                // register for push notifications
                registerForPushNotifications()
            } else {
                // if user has denied push notifications inform observers
                unregisteredForRemoteNotifications()
            }
        }
    }
    
    // MARK:
    // MARK: Private - Registration
    
    /// Register for push notifications
    private func registerForPushNotifications() {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
                guard error == nil || !granted else {
                    self?.subject.value = .unknown
                    return
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    // MARK:
    // MARK: Unregistration
    
    /// Remove device token held for device id (unregister)
    public func unregisterForPushNotifications() {
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            removeDeviceToken(deviceId: deviceId)
        }
    }
    
    // MARK:
    // MARK: Device Token
    
    /// Add device token
    ///
    /// - Parameters:
    ///   - deviceToken: token
    ///   - deviceId: unique device id i.e UIDevice.currentDevice.identifierForVendor?.uuidString or a custom id
    /// - Returns: result of updating device token
    @discardableResult
    public func update(deviceToken: Data, deviceId: String?) -> NexmoConversation.Observable<Bool> {
        guard let deviceId = deviceId else { return RxSwift.Observable<Bool>.just(false).wrap }
        
        return RxSwift.Observable<Bool>.create { observer -> Disposable in
            self.networkController.pushNotificationService.update(deviceToken: deviceToken, deviceId: deviceId, success: {
                observer.onNextWithCompleted(true)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
        }
        .wrap
    }
    
    /// Remove device token with your given device iD
    ///
    /// - Parameters:
    ///   - deviceId: unique device id i.e UIDevice.currentDevice.identifierForVendor?.uuidString or a custom id
    @discardableResult
    public func removeDeviceToken(deviceId: String?) -> NexmoConversation.Observable<Bool> {
        guard let deviceId = deviceId else { return RxSwift.Observable<Bool>.just(false).wrap }

        return RxSwift.Observable<Bool>.create { observer -> Disposable in
            self.networkController.pushNotificationService.removeDeviceToken(deviceId: deviceId, success: {
                observer.onNextWithCompleted(true)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
        }
        .wrap
    }
    
    // MARK:
    // MARK: Remote Notification
    
    /// Register for remote notifications with device token
    public func registeredForRemoteNotifications(with deviceToken: Data) {
        subject.value = .registeredWithDeviceToken(deviceToken)
    }
    
    /// Unregister for remote notifications
    public func unregisteredForRemoteNotifications() {
        subject.value = .unregisteredForRemoteNotifications
    }
}

/// Compare Push Notification States
///
/// - Parameters:
///   - lhs: PushNotificationState
///   - rhs: PushNotificationState
/// - Returns: result
/// :nodoc:
public func ==(lhs: PushNotificationController.State, rhs: PushNotificationController.State) -> Bool {
    switch (lhs, rhs) {
    case (.unknown, .unknown): return true
    case (.unregisteredForRemoteNotifications, .unregisteredForRemoteNotifications): return true
    case (.registeredWithDeviceToken(_), .registeredWithDeviceToken(_)): return true
    case (.registerForRemoteNotificationsFailed(_), .registerForRemoteNotificationsFailed(_)): return true
    case (.receivedRemoteNotification(_, _), .receivedRemoteNotification(_, _)): return true
    case (.unknown, _),
         (.unregisteredForRemoteNotifications, _),
         (.registeredWithDeviceToken, _),
         (.registerForRemoteNotificationsFailed, _),
         (.receivedRemoteNotification, _): return false
    }
}
