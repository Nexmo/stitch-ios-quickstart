//
//  Call.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 22/01/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Call Object used to help create a simple call
@objc(NXMCall)
public class Call: NSObject {
    
    // MARK:
    // MARK: Properties
    
    /// Conversation
    private let conversation: Conversation
    
    /// RTC
    private weak var controller: MediaController?
    
    /// Rx
    private let disposeBag = DisposeBag()
    
    /// Username of who initiated call
    private let state: Media.State  = .idle
    
    /// Username of who initiated call
    public let from: String?
    
    /// Usernames of everyone on the call
    public var to: [Member] { return conversation.members.filter { from != $0.user.name } }
    
    /// :nodoc:
    public override var hashValue: Int { return conversation.uuid.hashValue }
    
    // MARK:
    // MARK: Initializers
    
    /// Create call object for new call
    internal init(with conversation: Conversation, from username: String?, rtc: MediaController) {
        self.conversation = conversation
        self.controller = rtc
        self.from = username
        
        super.init()
    }
    
    // MARK:
    // MARK: Call
    
    /// Accept incoming calls
    ///
    /// - Parameters:
    ///   - onSuccess: Call has been answered
    ///   - onFailure: Failed to answer call with error
    public func answer(onSuccess: @escaping () -> Void, onFailure: @escaping ((Error) -> Void)) {
        conversation.join(onSuccess: { [weak self] in
            do {
                // enable check the device setting, if there a active call in progress and if it already connected
                try self?.conversation.media.enable()
                
                onSuccess()
            } catch let error {
                onFailure(error)
            }
        }, onFailure: onFailure)
    }
    
    /// Reject incoming call
    ///
    /// - Parameter onFailure: Failed to reject call with error
    public func reject(_ onFailure: ((Error) -> Void)?=nil) {
        conversation
            .leave()
            .subscribe(onError: onFailure)
    }
    
    /// Terminate the call
    ///
    /// - Parameters:
    ///   - onSuccess: Call hanged up
    ///   - onFailure: Failed to hang up call with error
    public func hangUp(onSuccess: @escaping () -> Void, onFailure: ((Error) -> Void)?=nil) {
        // disable
        conversation.media.disable()
    
        // kick members - if its a group call only leave otherwise just kick everyone out
        let members = conversation.members.count > 2
            ? [conversation.ourMemberRecord?.kick().rx].flatMap { $0 }
            : conversation.members.map { $0.kick().rx }
        
        RxSwift.Observable.combineLatest(members)
            .do(onCompleted: { Log.info(.rtc, "Call: \(self.conversation.name) hanged up") })
            .subscribe(onError: onFailure, onCompleted: onSuccess)
            .disposed(by: disposeBag)
    }
}
