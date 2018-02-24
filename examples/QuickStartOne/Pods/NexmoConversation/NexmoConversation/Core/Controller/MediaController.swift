//
//  MediaController.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Controller for Media event such as Audio and Video
@objc(NXMMediaController)
public class MediaController: NSObject {

    // MARK:
    // MARK: Typealias

    /// Conversation who been invited to start new media (Audio, Video)
    public typealias Invitation = (conversation: Conversation, member: Member, type: Media)

    /// Result of creating a call object
    public typealias CallResult = (call: Call, error: [Error])
    
    // MARK:
    // MARK: Enum

    internal enum Errors: Error {
        case dupeConversation
        case mediaIsCurrentlyInSession
    }

    // MARK:
    // MARK: Enum

    /// Media type
    ///
    /// - none: non media
    /// - audio: audio enabled
    /// - video: video enabled
    public enum Media: Int {
        /// non media
        case none
        ///  audio enabled
        case audio
        /// video enabled
        case video
    }

    // MARK:
    // MARK: Properties - Observable

    /// Observe for incoming conversations with audio enabled
    public var invitations: NexmoConversation.Observable<Invitation> {
        return self.invitationVariable
            .asObservable()
            .unwrap()
            .observeOnMainThread()
            .share()
            .wrap
    }
    
    /// Register for receiving inbound Calls from another member
    public var inboundCalls: NexmoConversation.Observable<Call> {
        return self.inboundCallsVariable
            .asObservable()
            .unwrap()
            .observeOnMainThread()
            .share()
            .wrap
    }
    
    // MARK:
    // MARK: Properties
    
    /// New conversation with invite media
    internal let invitationVariable = RxSwift.Variable<Invitation?>(nil)
    
    /// New inbound calls
    internal let inboundCallsVariable = RxSwift.Variable<Call?>(nil)

    /// New answers
    internal let answers = RxSwift.Variable<RTC.Answer?>(nil)

    /// Device details
    internal let device = RTCDevice()

    /// Network controller
    internal let networkController: NetworkController

    /// Enabled media which are currently active
    internal private(set) var activeMedia = [NexmoConversation.Media?]()

    /// conversation controller. @Set after object is created
    internal var conversationController: ConversationController?
    
    /// Rx
    internal let disposeBag = DisposeBag()

    /// Retry count
    private var retries: Int = 0
    private var maxRetries: Int = 5
    
    // MARK:
    // MARK: Initializers

    internal init(network: NetworkController) {
        networkController = network

        super.init()
        
        setup()
    }

    // MARK:
    // MARK: Private - Setup

    private func setup() {
        bindListener()
    }

    // MARK:
    // MARK: Private - Bind

    private func bindListener() {
        answers
            .asObservable()
            .unwrap()
            .subscribe(onNext: { self.connect(with: $0) })
            .disposed(by: disposeBag)

        device.audioRouteChanged
            .filter { $0 == .routeConfigurationChange && self.device.loudspeaker }
            .subscribe(onNext: { _ in self.device.loudspeaker = true }) // force another attempt to connect 
            .disposed(by: disposeBag)
    }

    // MARK:
    // MARK: Active Media 

    /// Enabled media
    internal func enabled(media: NexmoConversation.Media) throws {
        guard activeMedia.isEmpty else { throw Errors.mediaIsCurrentlyInSession }
        guard !activeMedia.contains(where: { $0?.conversation?.uuid == media.conversation?.uuid }) else { throw Errors.dupeConversation }

        activeMedia.append(media)
    }

    /// Remove disabled media and stop any supporting services
    @discardableResult
    internal func disabled(media: NexmoConversation.Media?) -> Bool {
        guard media != nil,
            let index = activeMedia.index(where: { $0?.conversation?.uuid == media?.conversation?.uuid }) else {
            return false
        }

        // remove from list
        let disabled = activeMedia.remove(at: index)

        // disable supporting services
        if disabled?.loudspeaker == true {
            device.loudspeaker = false
        }

        return true
    }

    // MARK:
    // MARK: Answer

    private func connect(with answer: RTC.Answer) {
        Log.info(.rtc, "Received RTC:answer for: \(answer.id)")
        
        if let audio = activeMediaForId(id: answer.id) {
            retries = 0
            audio.connect(with: answer)
        } else {
            //TODO fix race condition when we are told we are connected but dont have id yet
            if retries < maxRetries {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                    self?.retries += 1
                    self?.connect(with: answer)
                })
            }
        }
    }
    
    private func activeMediaForId(id: String) -> NexmoConversation.Media? {
        guard let audio = activeMedia.first(where: { id == $0?.id }) as? NexmoConversation.Media else {
            var conversations: String {
                guard !self.activeMedia.isEmpty else { return "No conversation found with active audio" }
                
                return String(self.activeMedia
                    .flatMap { $0 }
                    .reduce("", { $0 + "\($1.description), " })
                    .dropLast(2)
                )
            }
            
            Log.info(.rtc, "Unknown RTC:answer received active for: \(conversations) retries \(retries)")
            
            return nil
        }
        
        return audio
    }
}
