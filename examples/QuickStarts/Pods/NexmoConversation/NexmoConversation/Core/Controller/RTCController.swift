//
//  RTCController.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Controller for Media event such as Audio and Video
@objc(NXMRTCController)
public class RTCController: NSObject {

    // MARK:
    // MARK: Typealias

    /// Conversation who been invited to start new media (Audio, Video)
    public typealias Invitation = (conversation: Conversation, member: Member, type: Media)

    // MARK:
    // MARK: Enum

    internal enum Errors: Error {
        case dupeConversation
        case mediaIsInCurrentlyInSession
    }

    // MARK:
    // MARK: Enum

    /// Media type
    ///
    /// - none: none
    /// - audio: audio enabled
    /// - video: video enabled
    public enum Media: Int {
        case none
        case audio
        case video
    }

    // MARK:
    // MARK: Properties

    /// Observe for incoming conversations with audio enabled
    public var invitations: Observable<Invitation> {
        return self.invitationVariable
            .asObservable()
            .unwrap()
            .subscribeOnMainThread()
            .share()
    }

    /// New conversation with invite media
    internal let invitationVariable = Variable<Invitation?>(nil)

    /// New answers from CAPI
    internal let answers = Variable<RTC.Answer?>(nil)

    /// Device details
    internal let device = RTCDevice()

    /// Network controller
    internal let networkController: NetworkController

    /// Enabled media which are currently active
    private var activeMedia = [Audio?]()

    /// Rx
    private let disposeBag = DisposeBag()

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
    internal func enabled(media: Audio) throws {
        guard activeMedia.isEmpty else { throw Errors.mediaIsInCurrentlyInSession }
        guard !activeMedia.contains(where: { $0?.conversation?.uuid == media.conversation?.uuid }) else { throw Errors.dupeConversation }

        activeMedia.append(media)
    }

    /// Remove disabled media and stop any supporting services
    @discardableResult
    internal func disabled(media: Audio?) -> Bool {
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
    
    private func activeMediaForId(id: String) -> Audio? {
        guard let audio = activeMedia.first(where: { id == $0?.id }) as? Audio else {
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
