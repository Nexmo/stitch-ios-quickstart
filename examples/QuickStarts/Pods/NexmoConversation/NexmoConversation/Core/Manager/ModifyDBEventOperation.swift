//
//  ModifyDBEventOperation.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 11/05/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Operation to remove a event from the database
internal struct ModifyDBEventOperation: Operation {
    
    internal typealias T = Void
    
    internal enum Errors: Error {
        case eventNotFoundInCache
    }
    
    private let event: Event?
    private let task: DBTask?
    private let storage: Storage
    private let database: DatabaseManager
    
    private var uuid: String? {
        if let uuid = task?.related {
            return uuid
        } else if let cid = event?.cid, let id = event?.id {
            return EventBase.uuid(from: id, in: cid)
        }
        
        return nil
    }
    
    // MARK:
    // MARK: Initializers

    internal init(_ event: Event?, with task: DBTask?=nil, storage: Storage, database: DatabaseManager) {
        self.event = event
        self.task = task
        self.storage = storage
        self.database = database
    }
    
    // MARK:
    // MARK: Operation
    
    internal func perform() throws -> Maybe<T> {
        return Maybe<T>.create(subscribe: { observer in
            do {
                try self.modifyEvent()

                observer(.success(()))
                observer(.completed)
            } catch let error {
                observer(.error(error))
            }
            
            return Disposables.create()
        })
    }
    
    // MARK:
    // MARK: Private - Delete
    
    private func modifyEvent() throws {
        guard let event = event, let delete: Event.Body.Delete = try? event.model() else { throw Errors.eventNotFoundInCache }
        
        // delete task
        if let task = task {
            try database.task.delete(task)
        }
        
        let eventId = delete.event
        
        // find old event
        guard let oldDBEvent = storage.eventCache.get(uuid: EventBase.uuid(from: eventId, in: event.cid)) else {
            throw Errors.eventNotFoundInCache
        }

        // remove old event payload and mark as deleted
        let oldEvent = oldDBEvent.data.rest
        oldEvent.body = Event.Body.Deleted(with: event.timestamp).json

        // save events
        try database.event.update(DBEvent(conversationUuid: event.cid, event: oldEvent, seen: true))
        try database.event.insert(DBEvent(conversationUuid: event.cid, event: event, seen: true))

        let indexPath: [IndexPath] = {
            guard let index = oldDBEvent.conversation.events.index(of: oldDBEvent) else { return [] }

            return [IndexPath(index: index)]
        }()

        // remove the old event from cache
        storage.eventCache.clear(uuid: oldDBEvent.uuid)
        
        // update observer
        oldDBEvent.conversation.events.events.emit(([], EventCollection.Change.deletes(indexPath)))
    }
}
