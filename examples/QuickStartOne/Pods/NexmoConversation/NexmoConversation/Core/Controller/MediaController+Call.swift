//
//  MediaController+Call.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 22/01/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Media Controller for calling
public extension MediaController {
    
    // MARK:
    // MARK: Call
    
    /// Make a call
    ///
    /// - Parameter usernames: List of usernames to call
    ///   - onSuccess: Active Call object
    ///   - onFailure: Reason of error
    /// - Throws: Device permission error for audio
    public func call(_ usernames: [String], onSuccess: @escaping (CallResult) -> Void, onFailure: @escaping (Error) -> Void) throws {
        Log.info(.rtc, "Creating call")
        // check permission
        guard device.hasAudioPermission else { throw NexmoConversation.Media.Errors.userHasNotGrantedPermission }
        // check parameters
        guard !usernames.isEmpty else { throw ConversationClient.Errors.missingParameters }
        // unwrap
        guard let controller = conversationController else { throw ConversationClient.Errors.userNotInCorrectState }
        
        let title = CallFactory.buildTitle(with: usernames, using: controller)
        let activeMediaSession = activeMedia.compactMap()
        
        // check there isn't a active media with the same name
        guard !activeMediaSession.contains(where: { $0.conversation?.name == title }) else {
            throw NexmoConversation.Media.Errors.activeMediaSessionWithSameNameInProgress
        }
        
        // check there isn't any active media
        guard activeMediaSession.isEmpty else {
            throw NexmoConversation.Media.Errors.userHasEnabledMediaInAnotherConversation
        }
        
        CallFactory
            .call(with: usernames, using: controller, rtc: self)
            .subscribe(
                onNext: onSuccess,
                onError: onFailure
            )
            .disposed(by: disposeBag)
    }
}
