//
//  MediaController+RTC.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 30/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

internal extension MediaController {

    // MARK:
    // MARK: RTC

    /// Enable media(.audio/.video) in a conversation
    ///
    /// - Parameters:
    ///   - conversationId: conversation id
    ///   - from: member id
    ///   - sdp: sdp
    /// - Returns: Result of request
    internal func new(_ conversationId: String, from: String, with sdp: String) -> Single<RTC.Response> {
        return Single<RTC.Response>.create { observer in
            let model = RTCService.New(from: from, sdp: sdp, id: self.networkController.sessionId)

            self.networkController.rtcService.new(conversationId, from: model, success: { response in
                observer(.success(response))
            }, failure: { error in
                observer(.error(error))
            })

            return Disposables.create()
            }
            .observeOnBackground()
    }

    /// Terminate media
    ///
    /// - Parameters:
    ///   - conversationId: conversation id
    ///   - from: member id
    ///   - sdp: sdp
    /// - Returns: Result of request
    internal func end(_ RTCId: String, in conversationId: String, from memberId: String) -> Completable {
        return Completable.create { observer in
            let session = RTCService.Session(conversationId: conversationId, RTCId: RTCId)

            self.networkController.rtcService.terminate(session, from: memberId, success: { _ in
                observer(.completed)
            }, failure: { error in
                observer(.error(error))
            })

            return Disposables.create()
            }
            .observeOnBackground()
    }

    /// Send RTC event
    internal func send(_ RTCId: String, in conversationId: String, to memberId: String, with type: Event.EventType) -> Completable {
        return Completable.create { observer in
            let request = RTC.Request(id: RTCId, conversationId: conversationId, to: memberId, type: type)

            self.networkController.rtcService.send(
                event: request,
                success: { observer(.completed) },
                failure: { observer(.error($0)) }
            )

            return Disposables.create()
            }
            .observeOnBackground()
    }
}
