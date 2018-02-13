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
    // MARK: Properties
    
    /// Push notification state
    internal var subject = Variable<PushNotificationState?>(nil)
    /// Push notification state observable
    public var state: Observable<PushNotificationState> {
        return subject.asObservable().unwrap().share()
    }
    
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
                guard error == nil else {
                    self?.subject.value = .unknown
                    return
                }
                
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    // user has denied permissions
                    self?.subject.value = .unknown
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
    public func update(deviceToken: Data, deviceId: String?) -> Observable<Bool> {
        guard let deviceId = deviceId else { return Observable<Bool>.just(false) }
        
        return Observable<Bool>.create { observer -> Disposable in
            self.networkController.pushNotificationService.update(deviceToken: deviceToken, deviceId: deviceId, success: {
                observer.onNextWithCompleted(true)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
        }
    }
    
    /// Remove device token with your given device iD
    ///
    /// - Parameters:
    ///   - deviceId: unique device id i.e UIDevice.currentDevice.identifierForVendor?.uuidString or a custom id
    @discardableResult
    public func removeDeviceToken(deviceId: String?) -> Observable<Bool> {
        guard let deviceId = deviceId else { return Observable<Bool>.just(false) }

        return Observable<Bool>.create { observer -> Disposable in
            self.networkController.pushNotificationService.removeDeviceToken(deviceId: deviceId, success: {
                observer.onNextWithCompleted(true)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
        }
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
