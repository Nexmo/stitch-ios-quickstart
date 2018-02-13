//
//  SubscriptionService.swift
//  NexmoConversation
//
//  Created by shams ahmed on 22/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Service for all custom listeners 
internal struct SubscriptionService {

    /// Unknown types from CAPI
    internal typealias GenericsResponse = (type: Event.EventType, json: [String: Any])

    /// New events from capi socket
    internal let events = Variable<Event?>(nil)

    /// New rtc events
    internal let rtc = Variable<GenericsResponse?>(nil)
    
    private let webSocketManager: WebSocketManager
    
    private let disposeBag = DisposeBag()
    
    /// Processing queue for new eventss
    private let serialDispatchQueue: SerialDispatchQueueScheduler
    
    // MARK:
    // MARK: Initializers
    
    internal init(webSocketManager: WebSocketManager) {
        self.webSocketManager = webSocketManager
        serialDispatchQueue = SerialDispatchQueueScheduler(
            queue: webSocketManager.queue, 
            internalSerialQueueName: webSocketManager.queue.label
        )
        
        setup()
    }
    
    // MARK:
    // MARK: Private - Setup
    
    private func setup() {
        bindMemberListener()
        bindTextListener()
        bindEventListener()
        bindRTCListener()

        if Environment.inDebug {
            bindUnknownListener()
        }
    }
    
    // MARK:
    // MARK: Private - binding
    
    private func bindMemberListener() {
        webSocketManager.on(Event.EventType.memberInvited.rawValue) { self.handleEvent(.memberInvited, with: $0) }
        webSocketManager.on(Event.EventType.memberJoined.rawValue) { self.handleEvent(.memberJoined, with: $0) }
        webSocketManager.on(Event.EventType.memberLeft.rawValue) { self.handleEvent(.memberLeft, with: $0) }
    }
    
    private func bindTextListener() {
        webSocketManager.on(Event.EventType.textTypingOn.rawValue) { self.handleEvent(.textTypingOn, with: $0) }
        webSocketManager.on(Event.EventType.textTypingOff.rawValue) { self.handleEvent(.textTypingOff, with: $0) }
        webSocketManager.on(Event.EventType.textSeen.rawValue) { self.handleEvent(.textSeen, with: $0) }
        webSocketManager.on(Event.EventType.textDelivered.rawValue) { self.handleEvent(.textDelivered, with: $0) }
        webSocketManager.on(Event.EventType.text.rawValue) { self.handleEvent(.text, with: $0) }
    }
    
    private func bindEventListener() {
        webSocketManager.on(Event.EventType.eventDelete.rawValue) { self.handleEvent(.eventDelete, with: $0) }
        webSocketManager.on(Event.EventType.image.rawValue) { self.handleEvent(.image, with: $0) }
        webSocketManager.on(Event.EventType.imageDelivered.rawValue) { self.handleEvent(.imageDelivered, with: $0) }
        webSocketManager.on(Event.EventType.imageSeen.rawValue) { self.handleEvent(.imageDelivered, with: $0) }
    }

    private func bindRTCListener() {
        webSocketManager.on(Event.EventType.rtcNew.rawValue) { self.handleRTCEvent(.rtcNew, with: $0) }
        webSocketManager.on(Event.EventType.rtcOffer.rawValue) { self.handleRTCEvent(.rtcOffer, with: $0) }
        webSocketManager.on(Event.EventType.rtcIce.rawValue) { self.handleRTCEvent(.rtcIce, with: $0) }
        webSocketManager.on(Event.EventType.rtcAnswer.rawValue) { self.handleRTCEvent(.rtcAnswer, with: $0) }
        webSocketManager.on(Event.EventType.rtcTerminate.rawValue) { self.handleRTCEvent(.rtcTerminate, with: $0) }
        webSocketManager.on(Event.EventType.memberMedia.rawValue) { self.handleRTCEvent(.memberMedia, with: $0) }
        webSocketManager.on(Event.EventType.audioPlay.rawValue) { self.handleRTCEvent(.audioPlay, with: $0) }
        webSocketManager.on(Event.EventType.audioPlayDone.rawValue) { self.handleRTCEvent(.audioPlayDone, with: $0) }
        webSocketManager.on(Event.EventType.audioSay.rawValue) { self.handleRTCEvent(.audioSay, with: $0) }
        webSocketManager.on(Event.EventType.audioSayDone.rawValue) { self.handleRTCEvent(.audioSayDone, with: $0) }
        webSocketManager.on(Event.EventType.audioDtmf.rawValue) { self.handleRTCEvent(.audioDtmf, with: $0) }
        webSocketManager.on(Event.EventType.audioRecord.rawValue) { self.handleRTCEvent(.audioRecord, with: $0) }
        webSocketManager.on(Event.EventType.audioRecordDone.rawValue) { self.handleRTCEvent(.audioRecordDone, with: $0) }
        webSocketManager.on(Event.EventType.audioUnmute.rawValue) { self.handleRTCEvent(.audioUnmute, with: $0) }
        webSocketManager.on(Event.EventType.audioUnearmuff.rawValue) { self.handleRTCEvent(.audioEarmuffed, with: $0) }
        webSocketManager.on(Event.EventType.audioSpeakingOff.rawValue) { self.handleRTCEvent(.audioSpeakingOff, with: $0) }
        webSocketManager.on(Event.EventType.audioMute.rawValue) { self.handleRTCEvent(.audioMute, with: $0) }
        webSocketManager.on(Event.EventType.audioEarmuffed.rawValue) { self.handleRTCEvent(.audioEarmuffed, with: $0) }
        webSocketManager.on(Event.EventType.audioSpeakingOn.rawValue) { self.handleRTCEvent(.audioSpeakingOn, with: $0) }
        webSocketManager.on(Event.EventType.sipHangUp.rawValue) { self.handleRTCEvent(.sipHangUp, with: $0) }
    }

    private func bindUnknownListener() {
        webSocketManager.any { event in
            guard Event.EventType(rawValue: event.event) == nil else { return }
            guard WebSocketManager.Event(rawValue: event.event) == nil else { return }
            guard SocketService.Event(rawValue: event.event) == nil else { return }

            Log.info(.websocket, "Unknown event(\(event.event)) from socket: \(event.items ?? [])")
        }
    }

    // MARK:
    // MARK: Private - Handler
    
    private func handleEvent(_ event: Event.EventType, with data: [Any]) {
        Observable<Event>.create { observer in
            guard let json = data.first as? [String: Any] else { return Disposables.create() }
            guard let model = Event(type: event, json: json) else { return Disposables.create() }
            
            observer.onNextWithCompleted(model)
            
            return Disposables.create()
            }
            .subscribeOn(serialDispatchQueue)
            .bind(to: events)
            .disposed(by: disposeBag)
    }

    private func handleRTCEvent(_ event: Event.EventType, with data: [Any]) {
        guard let json = data.first as? [String: Any] else { return }

        rtc.value = GenericsResponse(event, json)
    }
}
