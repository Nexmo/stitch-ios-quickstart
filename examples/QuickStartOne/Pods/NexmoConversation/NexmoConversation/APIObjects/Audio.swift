//
//  Audio.swift
//  NexmoConversation
//
//  Created by May Ben Arie on 9/27/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift
import WebRTC

/// Facade for Audio
public class Audio: NSObject {

    // MARK:
    // MARK: Enum

    /// Audio state
    ///
    /// - idle: inital state
    /// - connecting: connecting to audio
    /// - connected: audio connected
    /// - disconnected: audio disconnected
    /// - failed: failed to enable audio
    @objc(NXMAudioState)
    public enum State: Int {
        case idle
        case connecting
        case connected
        case disconnected
        case failed
    }
    
    /// Audio Error
    ///
    /// - isAlreadyConnected: user has already connected to audio
    /// - isAlreadyEnabled: user has enabled audio
    /// - userHasNotGrantedPermission: user has granted permission to start using audio
    /// - userHasEnabledAudioInAnotherConversation: user is in another audio session
    public enum Errors: Error {
        case isAlreadyConnected
        case isAlreadyEnabled
        case userHasNotGrantedPermission
        case userHasEnabledAudioInAnotherConversation
    }

    // MARK:
    // MARK: Properties

    /// Current state
    public let state = Variable<State>(.idle)

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
    
    /// RTC controller
    internal let controller: RTCController

    /// Connecting for Audio session
    private let connection = RTCConnection()

    /// Rx
    internal let disposeBag = DisposeBag()
    
    // MARK:
    // MARK: Hashable
    
    /// Audio hashable value
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

    /// Description
    public override var description: String {
        return "Audio rtc id: \(id ?? "Unknown") for conversation \(conversation?.uuid ?? "Unknown")"
    }

    // MARK:
    // MARK: Audio

    /// Enable audio
    ///
    /// - Returns: observable of state property
    /// - Throws: error that affects enabling audio
    @discardableResult
    public func enable() throws -> Observable<State> {
        Log.info(.rtc, "Enable audio at: \(Date())")

        try hasAudioPermission()

        guard !state.isConnectState else { throw Errors.isAlreadyConnected }

        do {
            try controller.enabled(media: self)
        } catch RTCController.Errors.dupeConversation {
            throw Errors.isAlreadyEnabled
        } catch RTCController.Errors.mediaIsInCurrentlyInSession {
            throw Errors.userHasEnabledAudioInAnotherConversation
        }

        state.value = .connecting

        connection.setLocalSDP {
            switch $0 {
            case .success(let sdp):
                do {
                    try self.sendRTC(with: sdp)
                } catch {
                    self.state.value = .failed
                }
            case .failed(let error):
                Log.info(.rtc, "Local sdp failed: \(error)")
                
                self.state.value = .failed
            }
        }

        return state.asObservable()
    }

    /// Disable audio call
    ///
    /// - Returns: result of disabling audio
    public func disable() {
        terminate()

        connection.close()
        controller.disabled(media: self)

        id = nil
        state.value = .disconnected
    }

    // MARK:
    // MARK: Internal - Connection

    /// Connect to a remote sdp - in case of outbound calls only
    internal func connect(with answer: RTC.Answer) {
        Log.info(.rtc, "Connecting with RTC:Answer")

        connection.setRemoteSDP(answer.sdp) {
            switch $0 {
            case .success: self.state.value = .connected
            case .failed: self.state.value = .failed
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
            self.state.value = .connected
        }, onError: { error in
            Log.info(.rtc, "Failed to create RTC:new with error: \(error)")
            self.state.value = .failed
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
            media.audioTracks.forEach { $0.isEnabled = mute }
        }

        sendEvent(mute ? .audioMute : .audioUnmute, to: conversation?.ourMemberRecord)

        Log.info(.rtc, "Audio state: \(mute ? "Muted" : "Unmuted")")
    }

    private func earmuff(_ earmuff: Bool) {
        sendEvent(earmuff ? .audioEarmuffed : .audioUnearmuff, to: conversation?.ourMemberRecord)

        Log.info(.rtc, "Audio state: \(earmuff ? "Earmuffed" : "Unearmuff")")
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
public func ==(lhs: Audio, rhs: Audio) -> Bool {
    return lhs.hashValue == rhs.hashValue && lhs.hashValue != 0 && rhs.hashValue != 0
}
