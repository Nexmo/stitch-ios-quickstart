//
//  AccountController.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 28/10/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Account controller to handle all account actions
@objc(NXMAccountController)
public class AccountController: NSObject {
    
    // MARK:
    // MARK: Enum
    
    /// Account state
    ///
    /// - loggedOut: user is logged out
    /// - loggedIn: user has been logged in, @parameter includes session model
    public enum State: Equatable {
        /// user is logged out
        case loggedOut
        /// user has been logged in, @parameter includes session model
        case loggedIn(Session)
    }
    
    // MARK:
    // MARK: Properties
    
    /// Nexmo application id
    public static var applicationId: String {
        guard !Environment.inTesting else {
            Log.info(.other, "Application Id has not been set, push notification support will be disabled.")

            return ""
        }

        guard let nexmo = Bundle.main.object(forInfoDictionaryKey: Constants.Keys.nexmoDictionary) as? [String: Any],
            let applicationID = nexmo[Constants.Keys.applicationID] as? String else {
            Log.info(.other, "Application Id has not been set, push notification support will be disabled.")

            return ""
        }

        return applicationID
    }
    
    /// API session token
    public internal(set) var token: String? {
        get {
            return Keychain()[.token]
        }
        set {
            if let newValue = newValue {
                Keychain()[.token] = newValue
            } else {
                Keychain().remove(forKey: .token)
            }
        }
    }
    
    /// User id of current user
    internal internal(set) var userId: String? {
        get {
            let username = Keychain()[.username]
            
            return username
        }
        set {
            if let newValue = newValue {
                Keychain()[.username] = newValue
            } else {
                Keychain().remove(forKey: .username)
            }
        }
    }
    
    /// Current logged in User
    public var user: User? {
        guard let userId = userId else { return nil }
        
        assert(self.storage != nil, "storage not been set post init method")
        
        return self.storage?.userCache.get(uuid: userId)
    }
    
    /// Network controller
    private let networkController: NetworkController
    internal weak var storage: Storage?
    
    /// Rx
    internal let disposeBag = DisposeBag()
    
    // MARK:
    // MARK: Properties - Observable

    /// User login state
    public let state = MutableObservable(RxSwift.Variable<State>(.loggedOut))

    // MARK:
    // MARK: Initializers
    
    internal init(network: NetworkController) {
        networkController = network
    }
    
    // MARK:
    // MARK: Account
    
    /// Remove all user information from device
    public func removeUserData() {
        token = nil
        networkController.token = ""
        networkController.sessionId = ""
    }

    // MARK:
    // MARK: User
    
    /// Fetch user object with a uuid
    ///
    /// - Parameters:
    ///   - uuid: user uuid
    /// - Returns: observable with User object result
    public func user(with id: String) -> NexmoConversation.Observable<User> {
        return RxSwift.Observable<User>.create { [weak self] observer in
            self?.networkController.accountService.user(
                with: id,
                success: { userModel in
                    let user = User(from: userModel)
                    
                    observer.onNextWithCompleted(user)
            },
                failure: { observer.onError($0) }
            )
            
            return Disposables.create()
        }
        .observeOnBackground()
        .wrap
    }
}

// MARK:
// MARK: Compare

/// Compare login state
///
/// - Parameters:
///   - lhs: state
///   - rhs: state
/// - Returns: result
/// :nodoc:
public func ==(lhs: AccountController.State, rhs: AccountController.State) -> Bool {
    switch (lhs, rhs) {
    case (.loggedOut, .loggedOut): return true
    case (.loggedIn, .loggedIn): return true
    case (.loggedOut, _),
         (.loggedIn, _): return false
    }
}
