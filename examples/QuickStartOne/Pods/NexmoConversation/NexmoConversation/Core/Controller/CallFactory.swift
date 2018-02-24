//
//  CallFactory.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 23/01/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Create call object
internal struct CallFactory {
    
    // MARK:
    // MARK: Initializers
    
    private init() {
        
    }
    
    // MARK:
    // MARK: Call
    
    /// Create inbound call object
    internal static func call(with conversation: Conversation, from username: String?, rtc: MediaController) -> Call {
        let call = Call(with: conversation, from: username, rtc: rtc)
        // TODO: set the call status to ringing
        
        return call
    }
    
    /// Create outbound call object
    internal static func call(with usernames: [String], using controller: ConversationController, rtc: MediaController) -> RxSwift.Observable<MediaController.CallResult> {
        var errors = [Error]()
        var conversation: Conversation?
        let title = CallFactory.buildTitle(with: usernames, using: controller)
        
        return controller
            .new(title, withJoin: true) // create conversation with join
            .rx
            .do(onNext: { conversation = $0 })
            .flatMap { conversation -> RxSwift.Observable<[Void]> in // invite everyone
                Log.info(.rtc, "Inviting users to the call: \(conversation.name)")
                
                let invites = usernames.map {
                    conversation.invite($0, with: .audio(muted: false, earmuffed: false))
                        .rx
                        .catchError { error in
                            Log.warn(.rtc, "Failed to invite a user to the call: \(conversation.name)")
                        
                            errors.append(error)
                        
                            return RxSwift.Observable.just(nil)
                        }
                }
                
                return RxSwift.Observable
                    .combineLatest(invites)
                    .map { $0.compactMap() } // remove failed invite and check if there one at least success, otherwise error
                    .flatMap { $0.isEmpty ? RxSwift.Observable.error(Conversation.Errors.usernameNotFound) : RxSwift.Observable.just($0) }
            }
            .map { _ in conversation }
            .unwrap()
            .do(onNext: { _ = try? $0.media.enable() }) // enable audio
            .map { MediaController.CallResult(
                call: Call(with: $0, from: conversation?.account.user?.name, rtc: rtc),
                error: errors)
            } // create call object with enabled audio
    }
    
    // MARK:
    // MARK: Helper
    
    internal static func buildTitle(with usernames: [String], using controller: ConversationController) -> String {
        // build name
        let separator = "_"
    
        let name: String = {
            guard let name = controller.account.user?.name else { return "" }
    
            return name + separator
        }()
    
        let title = Conversation.ReservedPrefix.call.rawValue + name + usernames.joined(separator: separator)
    
        return title
    }
}
