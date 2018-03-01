//
//  SendEventOperation.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 13/05/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Operation: Sending events
internal struct SendEventOperation: Operation {
    
    internal typealias T = EventResponse?
    
    internal enum Errors: Error {
        case failedToProcessEvent
    }
    
    private let event: EventBase
    private let eventController: EventController

    internal let progress: (Request) -> Void

    // MARK:
    // MARK: Initializers

    internal init(_ event: EventBase, eventController: EventController, progress: @escaping (Request) -> Void) {
        self.event = event
        self.eventController = eventController
        self.progress = progress
    }
    
    // MARK:
    // MARK: Operation
    
    internal func perform() throws -> Maybe<T> {
        switch event {
        case let image as ImageEvent: return try send(image, progress: progress)
        case let text as TextEvent: return try send(text, progress: progress)
        default: throw Errors.failedToProcessEvent
        }
    }
    
    // MARK:
    // MARK: Private - Request

    private func send(_ event: TextEvent, progress: @escaping (Request) -> Void) throws -> Maybe<T> {
        guard let text = event.text else { throw Errors.failedToProcessEvent }
        
        let model = SendEvent(conversationId: event.conversation.uuid, from: event.fromMember.uuid, text: text, tid: event.id)
        
        return eventController.send(model, progress: { _ in }).asMaybe()
    }
    
    private func send(_ event: ImageEvent, progress: @escaping (Request) -> Void) throws -> Maybe<T> {
        // create thumbnail model
        guard let model: Event.Body.Image = try? event.data.rest.model(),
            case .link(let id, _, _, _)? = model.image(for: .thumbnail) else { // by default to save local cached asset as thumbnail
            throw Errors.failedToProcessEvent
        }

        // fetch 
        return RxSwift.Observable<Data>.create { observer -> Disposable in
            self.eventController.storage.fileCache.get(id) { (object: Data?) in
                guard let data = object.value else { return observer.onError(Errors.failedToProcessEvent) }

                observer.onNextWithCompleted(data)
            }

            return Disposables.create()
        }.flatMap { data -> RxSwift.Observable<T> in
            let parameters: IPSService.UploadImageParameter = (
                image: data,
                size: (originalRatio: nil, mediumRatio: nil, thumbnailRatio: nil) // default values
            )

            return self.eventController.send(
                parameters,
                conversationId: event.conversation.uuid,
                fromId: event.fromMember.uuid,
                tid: event.id,
                progress: progress
            )
        }.do(onNext: { _ in
            self.eventController.storage.fileCache.remove(key: id)
        }).asMaybe()
    }
}
