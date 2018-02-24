//
//  ConversationController+ObjectiveC.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 31/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

public extension ConversationController {

    // MARK:
    // MARK: Properties - (Objective-C compatibility support)
    
    /// List of conversations, only for Objective-c suppoty
    @objc
    public var conversationsObjc: [Conversation] {
        return self.conversations.map { $0 }
    }
    
    // MARK:
    // MARK: Create (Objective-C compatibility support)
    
    /// Create a new conversation with join parameter
    ///
    /// - Parameters:
    ///   - name: conversation display name
    ///   - join: userid of the user wants to join
    ///   - onSuccess: conversation created in backend successfully, and conversation model object which was persisted in the local database is returned
    ///   - onFailure: error
    @objc
    public func new(with name: String, shouldJoin: Bool, _ onSuccess: @escaping (Conversation) -> Void, onFailure: ((Error) -> Void)?, onComplete: @escaping () -> Void) {
        new(name, withJoin: shouldJoin).subscribe(
            onSuccess: onSuccess,
            onError: onFailure
        )
    }
    
    // MARK:
    // MARK: Fetch (Objective-C compatibility support)
    
    /// Fetch a conversation
    ///
    /// - Parameters:
    ///   - id: conversation Id
    ///   - onSuccess: conversation model
    ///   - onFailure: error
    @objc
    public func conversation(with id: String, _ onSuccess: @escaping (Conversation) -> Void, onFailure: ((Error) -> Void)?) {
        conversation(with: id).subscribe(
            onSuccess: onSuccess,
            onError: onFailure
        )
    }

    /// Fetch all conversations
    ///
    /// - Parameters:
    ///   - onSuccess: all conversations uuid and name 
    ///   - onFailure: error
    @objc
    public func all(_ onSuccess: @escaping ([[String: String]]) -> Void, onFailure: ((Error) -> Void)?) {
        all().subscribe(
            onSuccess: { conversations in onSuccess(conversations.map { ["name": $0.name, "uuid": $0.uuid] }) },
            onError: onFailure
        )
    }
    
    /// Fetch all users conversations
    ///
    /// - Parameters:
    ///   - userId: user id
    ///   - onSuccess: all user conversation
    ///   - onFailure: error
    @objc
    public func all(with userId: String, _ onSuccess: @escaping ([ConversationPreviewModel]) -> Void, onFailure: ((Error) -> Void)?) {
        all(with: userId).subscribe(
            onSuccess: onSuccess,
            onError: onFailure
        )
    }
    
    // MARK:
    // MARK: Join (Objective-C compatibility support)
    
    /// Join a conversation
    ///
    /// - Parameters:
    ///   - userId: user id
    ///   - memberId: member id
    ///   - uuid: conversation id
    ///   - onSuccess: member state
    ///   - onFailure: error
    @objc
    public func join(userId: String, memberId: String?, uuid: String, _ onSuccess: @escaping (String) -> Void, onFailure: ((Error) -> Void)?) {
        let conversation = JoinConversation(userId: userId, memberId: memberId)
        
        join(conversation, forUUID: uuid).subscribe(
            onNext: { onSuccess($0.rawValue) },
            onError: onFailure
        ).disposed(by: disposeBag)
    }
}
