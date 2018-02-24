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
    public func login(with token: String?=nil) -> NexmoConversation.Observable<Void> {
        return RxSwift.Observable<Void>.create { [unowned self] observer in
            self.login(with: token, { result in
                switch result {
                case .success:
                    self.setupAfterLogin()
                    
                    return observer.onNext(())
                case .failed: return observer.onError(LoginResult.failed)
                case .invalidToken: return observer.onError(LoginResult.invalidToken)
                case .sessionInvalid: return observer.onError(LoginResult.sessionInvalid)
                case .expiredToken: return observer.onError(LoginResult.expiredToken)
                }
            })
            
            return Disposables.create()
        }
        .observeOn(ConcurrentDispatchQueueScheduler.utility)
        .subscribeOn(ConcurrentMainScheduler.instance)
        .observeOnMainThread()
        .wrap
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
        } catch {
            return false
        }
        
        conversation.conversations.refetch()
        account.token = nil
        account.state.subject.value = .loggedOut
        
        return true
    }
    
    // MARK:
    // MARK: Post-Login
    
    private func setupAfterLogin() {
        if ConversationClient.configuration.pushNotifications {
            self.appLifecycle.push.requestPermission()
        }
    }
}
