//
//  Media.swift
//  NexmoConversation
//
//  Created by May Ben Arie on 9/27/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift
import WebRTC

/// Facade for Media
@objc(NXMMedia)
public class Media: NSObject {

    // MARK:
    // MARK: Enum

    /// Media state
    ///
    /// - idle: inital state
    /// - connecting: connecting to audio
    /// - connected: audio connected
    /// - disconnected: audio disconnected
    /// - failed: failed to enable audio
    @objc(NXMMediaState)
    public enum State: Int {
        /// inital state
        case idle
        /// connecting to audio
        case connecting
        /// audio connected
        case connected
        /// audio disconnected
        case disconnected
        /// failed to enable audio
        case failed
    }
    
    /// Media Error
    ///
    /// - isAlreadyConnected: user has already connected to audio
    /// - isAlreadyEnabled: user has enabled audio
    /// - userHasNotGrantedPermission: user has granted permission to start using audio
    /// - userHasEnabledMediaInAnotherConversation: user is in another audio session
    public enum Errors: Error {
        /// user has already connected to a media
        case isAlreadyConnected
        /// user has enabled a media
        case isAlreadyEnabled
        /// user has granted permission to start using audio
        case userHasNotGrantedPermission
        /// user is in another media session
        case userHasEnabledMediaInAnotherConversation
        /// active media session in progress with the same name/users
        case activeMediaSessionWithSameNameInProgress
    }

    // MARK:
    // MARK: Properties

    /// Current state
    public let state = MutableObservable(RxSwift.Variable<State>(.idle))

    /// Mute audio
    public var mute: Bool = false {
        didSet { self.mute(mute) }
    }

    /// Earmuff audio
    public var earmuff: Bool = false {
        didSet { self.earmuff(earmuff) }
    }

    /// Hold audio
    public var hold: Bool = false {
        didSet { self.hold(hold) }
    }

    /// Change audio output
    public var loudspeaker: Bool = false {
        didSet { self.loudspeaker(loudspeaker) }
    }
    
    /// RTC id for audio session
    internal var id: String?

    /// Conversation
    internal weak var conversation: Conversation?
    
    /// Media controller
    internal let controller: MediaController

    /// Connecting for Media session
    private let connection = RTCConnection()

    /// Rx
    internal let disposeBag = DisposeBag()
    
    // MARK:
    // MARK: Hashable
    
    /// :nodoc:
    public override var hashValue: Int { return self.conversation?.uuid.hashValue ?? 0 }

    // MARK:
    // MARK: Initializers

    internal init(with conversation: Conversation) {
        Log.info(.rtc, "Creating audio object for: \(conversation.uuid)")

        self.controller = conversation.controller.media
        self.conversation = conversation

        super.init()
    }

    // MARK:
    // MARK: Description

    /// :nodoc:
    public override var description: String {
        return "Media rtc id: \(id ?? "Unknown") for conversation \(conversation?.uuid ?? "Unknown")"
    }

    // MARK:
    // MARK: Media

    /// Enable audio
    ///
    /// - Returns: observable of state property
    /// - Throws: error that affects enabling audio
    @discardableResult
    public func enable() throws -> NexmoConversation.Observable<State> {
        Log.info(.rtc, "Enable audio at: \(Date())")

        try hasAudioPermission()

        guard !state.subject.isConnectState else { throw Errors.isAlreadyConnected }

        do {
            try controller.enabled(media: self)
        } catch MediaController.Errors.dupeConversation {
            throw Errors.isAlreadyEnabled
        } catch MediaController.Errors.mediaIsCurrentlyInSession {
            throw Errors.userHasEnabledMediaInAnotherConversation
        }

        state.subject.value = .connecting

        connection.setLocalSDP {
            switch $0 {
            case .success(let sdp):
                do {
                    try self.sendRTC(with: sdp)
                } catch {
                    self.state.subject.value = .failed
                }
            case .failed(let error):
                Log.info(.rtc, "Local sdp failed: \(error)")
                
                self.state.subject.value = .failed
            }
        }
        
        return state.rx.wrap
    }

    /// Disable audio call
    ///
    public func disable() {
        terminate()

        connection.close()
        controller.disabled(media: self)

        id = nil
        state.subject.value = .disconnected
    }
    
    // MARK:
    // MARK: Ringing
    
    /// Send a ringing event
    public func startRinging() {
        sendEvent(.audioRingingStart, to: conversation?.ourMemberRecord)
    }
    
    /// Send a stop ringing event
    public func stopRinging() {
        sendEvent(.audioRingingStop, to: conversation?.ourMemberRecord)
    }

    // MARK:
    // MARK: Internal - Connection

    /// Connect to a remote sdp - in case of outbound calls only
    internal func connect(with answer: RTC.Answer) {
        Log.info(.rtc, "Connecting with RTC:Answer")

        connection.setRemoteSDP(answer.sdp) {
            switch $0 {
            case .success: self.state.subject.value = .connected
            case .failed: self.state.subject.value = .failed
            }
        }
    }

    // MARK:
    // MARK: Private - RTC

    /// Send RTC:New
    private func sendRTC(with sdp: RTCSessionDescription) throws {
        Log.info(.rtc, "Sending RTC:new")

        guard let conversation = conversation, let member = conversation.ourMemberRecord else {
            throw ConversationClient.Errors.userNotInCorrectState
        }

        controller.new(conversation.uuid, from: member.uuid, with: sdp.sdp).subscribe(onSuccess: { rtc in
            Log.info(.rtc, "Created RTC:new \(rtc.id)")
            
            self.id = rtc.id
            self.state.subject.value = .connected
        }, onError: { error in
            Log.info(.rtc, "Failed to create RTC:new with error: \(error)")
            self.state.subject.value = .failed
        }).disposed(by: disposeBag)
    }

    private func terminate() {
        guard let rtcId = id, let conversationId = conversation?.uuid, let member = conversation?.ourMemberRecord else { return }

        controller.end(rtcId, in: conversationId, from: member.uuid)
            .subscribe()
            .disposed(by: disposeBag)
    }

    @discardableResult
    private func sendEvent(_ type: Event.EventType, to member: Member?) -> Bool {
        guard let id = id, let conversation = conversation, let member = member else { return false }

        controller.send(id, in: conversation.uuid, to: member.uuid, with: type)
            .subscribe()
            .disposed(by: disposeBag)

        return true
    }

    // MARK:
    // MARK: Configuration

    private func mute(_ mute: Bool) {
        connection.peerConnection.localStreams.forEach { media in
            media.audioTracks.forEach {
                if $0.isEnabled != !mute {
                    $0.isEnabled = !mute
                }
            }
        }
        
        sendEvent(mute ? .audioMute : .audioUnmute, to: conversation?.ourMemberRecord)

        Log.info(.rtc, "Media state: \(mute ? "Muted" : "Unmuted")")
    }

    private func earmuff(_ earmuff: Bool) {
        sendEvent(earmuff ? .audioEarmuffed : .audioUnearmuff, to: conversation?.ourMemberRecord)

        Log.info(.rtc, "Media state: \(earmuff ? "Earmuffed" : "Unearmuff")")
    }

    private func hold(_ hold: Bool) {
        // TODO: add logic
    }

    private func loudspeaker(_ loudspeaker: Bool) {
        controller.device.loudspeaker = loudspeaker
    }
}

//
// Mark: Compare

/// :nodoc:
public func ==(lhs: Media, rhs: Media) -> Bool {
    return lhs.hashValue == rhs.hashValue && lhs.hashValue != 0 && rhs.hashValue != 0
}
