//
//  EventController.swift
//  NexmoConversation
//
//  Created by shams ahmed on 29/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Send/Manage event for a conversation
@objc(NXMEventController)
@objcMembers
internal class EventController: NSObject {
    
    /// Network controller
    private let networkController: NetworkController

    internal lazy var queue: EventQueue = {
        let queue = EventQueue(storage: self.storage, event: self)

        return queue
    }()

    /// Only for DI
    internal let storage: Storage

    /// Rx
    internal let disposeBag = DisposeBag()
    
    // MARK:
    // MARK: Initializers
    
    internal init(network: NetworkController, storage: Storage) {
        networkController = network
        self.storage = storage
    }
    
    // MARK:
    // MARK: Send
    
    /// Send a event
    ///
    /// - Parameters:
    /// - model: event model
    /// - progress: progress of sending a event
    /// - Returns: observable with event result
    internal func send(_ event: SendEvent, progress: @escaping (Request) -> Void) -> RxSwift.Observable<EventResponse?> {
        return RxSwift.Observable<EventResponse?>.create { observer -> Disposable in
            let request = self.networkController.eventService.send(event: event, success: { response in
                observer.onNextWithCompleted(response)
            }, failure: { error in
                observer.onError(error)
            })
            
            progress(request)
            
            return Disposables.create()
        }
        .observeOnBackground()
    }
    
    /// Send a image event
    ///
    /// - Parameters:
    /// - model: image model
    /// - conversationId: conversation id
    /// - fromId: member who sending the event
    /// - progress: progress of sending a event
    /// - Returns: observable with event result
    internal func send(_ image: IPSService.UploadImageParameter,
                       conversationId: String,
                       fromId: String,
                       tid: String,
                       progress: @escaping (Request) -> Void) -> RxSwift.Observable<EventResponse?> {
        return RxSwift.Observable<EventResponse?>.create { observer -> Disposable in
            self.networkController.eventService.upload(
                image: image,
                conversationId: conversationId,
                fromId: fromId,
                tid: tid,
                success: { observer.onNextWithCompleted($0) },
                failure: { observer.onError($0) },
                progress: progress
            )
            
            return Disposables.create()
        }
        .observeOnBackground()
    }
    
    // MARK:
    // MARK: Retrieve
    
    /// Retrieve events with a range
    /// Default to start: 0 end: 20
    ///
    /// - Parameters:
    /// - for: conversation uuid
    /// - with: range start/end
    /// - Returns: observable with list of events
    internal func retrieve(for uuid: String, with range: Range<Int> = Range<Int>(uncheckedBounds: (lower: 0, upper: 20))) -> RxSwift.Observable<[Event]> {
        return RxSwift.Observable<[Event]>.create { observer -> Disposable in
            self.networkController.eventService.retrieve(for: uuid, with: range, success: { response in
                observer.onNextWithCompleted(response)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
        }
        .observeOnBackground()
    }
    
    // MARK:
    // MARK: Delete
    
    /// Delete event
    ///
    /// - Parameters:
    ///   - eventId: eventId
    ///   - memberId: memberId
    ///   - uuid: uuid
    /// - Returns: Observable
    internal func delete(_ eventId: String, for memberId: String, in uuid: String) -> RxSwift.Observable<Event> {
        return RxSwift.Observable<Event>.create { observer -> Disposable in
            self.networkController.eventService.delete(eventId, for: memberId, in: uuid, success: { event in
                observer.onNextWithCompleted(event)
            }, failure: { error in
                observer.onError(error)
            })
            
            return Disposables.create()
        }
        .observeOnBackground()
    }
}
