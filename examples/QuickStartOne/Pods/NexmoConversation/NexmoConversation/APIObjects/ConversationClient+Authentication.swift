//
//  ConversationClient+Authentication.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 25/05/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Authentication
public extension ConversationClient {
 
    // MARK:
    // MARK: Authentication
    
    /// Login
    ///
    /// - Parameter token: Token used to validate login
    /// - Returns: Response of login request
    @nonobjc
    public func login(with token: String?=nil) -> Single<Void> {
        return Single<Void>.create(subscribe: { [unowned self] observer in
            self.login(with: token, { result in
                switch result {
                case .success:
                    // when logged in, request push notification permissions
                    if ConversationClient.configuration.pushNotifications {
                        self.appLifecycle.push.requestPermission()
                    }
                    
                    return observer(SingleEvent.success(()))
                case .failed: return observer(SingleEvent.error(LoginResult.failed))
                case .invalidToken: return observer(SingleEvent.error(LoginResult.invalidToken))
                case .sessionInvalid: return observer(SingleEvent.error(LoginResult.sessionInvalid))
                case .expiredToken: return observer(SingleEvent.error(LoginResult.expiredToken))
                }
            })
            
            return Disposables.create()
        })
        .observeOn(ConcurrentDispatchQueueScheduler.utility)
        .subscribeOn(ConcurrentMainScheduler.instance)
    }
    
    /// Log out user
    @discardableResult
    public func logout() -> Bool {
        appLifecycle.push.unregisterForPushNotifications()
        disconnect()
        
        // Clear persistent storage
        account.removeUserData()

        do {
            try storage.reset()
        } catch _ {
            return false
        }
        
        conversation.conversations.refetch()
        account.token = nil
        account.state.value = .loggedOut
        
        return true
    }
}
