//
//  AccountController+ObjectiveC.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 06/02/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

public extension AccountController {
    
    // MARK:
    // MARK: User (Objective-C compatibility support)

    /// Fetch user with a uuid
    ///
    /// - Parameters:
    ///   - uuid: user uuid
    ///   - onSuccess: user object
    ///   - onFailure: error
    @objc
    public func user(with id: String, _ onSuccess: @escaping (User) -> Void, onFailure: ((Error) -> Void)?) {
        user(with: id).subscribe(
            onNext: onSuccess,
            onError: onFailure
        ).disposed(by: disposeBag)
    }
}
