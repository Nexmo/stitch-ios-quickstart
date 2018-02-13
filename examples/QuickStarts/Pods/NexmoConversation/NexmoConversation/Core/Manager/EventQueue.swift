//
//  EventQueue.swift
//  NexmoConversation
//
//  Created by James Green on 13/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

// TODO: Class has to be abstract in its queues and jobs it can handle
internal class EventQueue: Queue {
    
    internal typealias QueueState = State
    
    /// Error handling from task queue
    ///
    /// - eventNotFound: database out of sync
    /// - failedToProcessEvent: failed to process message with reason
    /// - duplicateTask: trying to add a existing task
    internal enum Errors: Error {
        case eventNotFound
        case failedToProcessEvent
        case duplicateTask
    }
    
    /// Queue state
    ///
    /// - active: Queue has active jobs
    /// - inactive: Queue is ready to be used
    internal enum State: Equatable {
        case active(Int)
        case inactive
    }
    
    internal static var maximumParallelTasks: Int { return 5 }
    internal static var maximumRetries: Int { return 3 }
    
    /// State of queue
    internal var state: Variable<State> = Variable<State>(.inactive)
    
    private var workerThread: Thread? // Our worker thread.

    private var taskQueueCondition = NSCondition() // Semaphore for flagging updates to the event queue.
    private var sendMessageWatchers = [QueueObserver]()
    private var sendMessageWatchersCondition = NSCondition()
    private var paused = true // Start of paused, and wait for sync manager to enable us.
    
    private let database: DatabaseManager
    private let storage: Storage
    private let eventController: EventController
    
    /// Rx
    private let disposeBag = DisposeBag()
    
    /// should keep running while active
    private var active = false
    
    // MARK:
    // MARK: Initializers
    
    internal init(storage: Storage, event: EventController) {
        self.storage = storage
        eventController = event
        database = storage.databaseManager
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        /* Mark all tasks as not being processed. If we were previously stopped half way through
         processing something, we need to clear the status so that the main processing loop
         can find the task and begin processing it a refresh. */
        do {
            try self.database.task.clear()
        } catch (let error) {
            Log.error(.taskProcessor, "Task Manager failed to clear 'being processed' flag: " + error.localizedDescription)
        }
    }
    
    // MARK:
    // MARK: Task

    internal func add(_ type: DBTask.OperationType, with event: EventBase) throws {
        defer { self.signalTaskQueueChange() }
        
        guard !database.task.taskExist(type, for: event.uuid) else { throw Errors.duplicateTask }
        
        let task = DBTask(type)
        
        if type == .indicateDelivered || type == .indicateSeen {
            task.related = event.uuid
            
            try database.task.insert(task)
            
            return
        }
        
        try database.task.insert(task) // We do this save so that a primary key is allocated.

        /* Create a temporary unique event id for this send event. */
        if task.type == .send {
            let interval = Int64(NSDate().timeIntervalSince1970 * 1000)
            event.data.id = String(interval)
        }
        
        task.related = event.uuid
        
        try database.task.insert(task)
        
        // don't push draft event for a delete event
        guard type == .send else { return }
        
        try database.event.insert(event.data)
        
        let conversation = event.conversation
        conversation.events.newEventReceived.emit(event)
        conversation.refreshEvents()
        
        Log.info(.taskProcessor, "Scheduling event, task id = \(task.uuid ?? 0), draft event id = \(event.data.id)")
    }
    
    // MARK:
    // MARK: Start/Stop
    
    internal func close() {
        // throw everyting at the thread to kill it
        active = false
        workerThread?.cancel()
        workerThread = nil
    }
    
    internal func detach() {
        
    }
    
    internal func start() {
        active = true
        
        // ensure we have only have one worker thread. start() is called when socket state becomes 'connected', so if we reconnect we find ourselves in here again
        guard workerThread == nil else { return }
        
        workerThread = Thread(target: self, selector: #selector(EventQueue.worker(param:)), object: nil)
        workerThread?.start()

        setup()
    }
    
    internal func pause() {
        taskQueueCondition.lock()
        paused = true
        taskQueueCondition.signal()
        taskQueueCondition.unlock()
    }
    
    internal func enable() {
        taskQueueCondition.lock()
        paused = false
        taskQueueCondition.signal()
        taskQueueCondition.unlock()
    }
    
    private func signalTaskQueueChange() {
        taskQueueCondition.lock()
        taskQueueCondition.signal()
        taskQueueCondition.unlock()
    }
    
    internal func reconnect() {
        active = true // this will allow the run loop to continue
    }
    
    // MARK:
    // MARK: Worker
    
    @objc
    private func worker(param: NSObject) {
        defer {
            close()
        }

        // TODO: remove while(true), bad code smell that hard to understand. use another other loop
        while active {
            guard active else { break }
            
            taskQueueCondition.lock()
            
            let task = database.task.pending
            var hasPendingTask: Bool { return !self.database.task.pending.isEmpty }
            var fullyBusy: Bool { return self.database.task.active.count >= EventQueue.maximumParallelTasks }

            while !hasPendingTask || fullyBusy || paused { taskQueueCondition.wait() }
            
            taskQueueCondition.unlock()
            
            updateState(with: task.count)
            
            // TODO: Worker to be abstract where it only knows how to execute jobs, inner working left alone.
            task.forEach {
                // needs to be computed each time
                let fullyBusy = database.task.active.count >= EventQueue.maximumParallelTasks
                
                guard !fullyBusy else { return }
                
                switch $0.type {
                case .delete: try? start(delete: $0)
                case .send: try? start(event: $0)
                case .indicateDelivered, .indicateSeen: try? start(indicate: $0)
                }
            }
        }
    }
    
    // MARK:
    // MARK: Private - Operation
    
    // TODO: Needs to be decoupled
    private func start(event task: DBTask) throws {
        task.beingProcessed = true
        try database.task.insert(task)
        
        /* Get the draft event that corresponds to this task. */
        guard let eventUuid = task.related, let draftEvent = storage.eventCache.get(uuid: eventUuid) else {
            throw Errors.eventNotFound
        }
        
        Log.info(.taskProcessor, "Processing event to send, id = \(task.uuid ?? 0), draft event = \(eventUuid)")

        let progress: (Request) -> Void = { _ in
            // TODO: incomplete, have to refactor EventQueue to allow for reporting progress
        }

        try SendEventOperation(draftEvent, eventController: eventController, progress: progress).perform().subscribe({ [weak self] result in
            Log.info(.taskProcessor, "Finished sending event, id = \(task.uuid ?? 0), draft event = \(eventUuid)")
            
            switch result {
            case .success(let event): self?.processEvent(for: task, draftEvent: draftEvent, eventUuid: eventUuid, response: event)
            default: self?.retryTask(task: task)
            }
            
            if let pending = self?.database.task.pending.count {
                self?.updateState(with: pending)
            }
        }).disposed(by: disposeBag)
    }
    
    private func processEvent(for task: DBTask, draftEvent: EventBase, eventUuid: String, response model: EventResponse?) {
        /* We now need to ensure we have an event handler for noticing when the sync manager pulls the newly sent message.
         If we were previously not looking for anything we need to add a handler. */
        self.sendMessageWatchersCondition.lock()
        
        guard let newEventId = model?.id else { return }
        
        if self.sendMessageWatchers.isEmpty {
            /* Add the handler. */
            let handlerRef = draftEvent.conversation.events.newEventReceived.addHandler(self, handler: EventQueue.watchForNewMessages)
            
            /* Remember details of the message we are waiting to see. */
            let watcher = QueueObserver(
                conversation: draftEvent.conversation,
                draftMessage: draftEvent, 
                sentMessageEventId: newEventId,
                handlerRef: handlerRef
            )
            
            self.sendMessageWatchers.append(watcher)
        }
        
        self.sendMessageWatchersCondition.unlock()
        
        /* Update our database. */
        do {
            try self.database.task.delete(task)
            
            // The sync manager will replace the draftMessage with the sent version once it is received based on tid returned in body
            
            try self.database.event.update(draftEvent.data)
            
            // Remove the old message from the cache.
            self.storage.eventCache.clear(uuid: eventUuid)
            
            self.signalTaskQueueChange()
        } catch {
            Log.error(.database, "Failed to Delete/Save record")
        }
    }
    
    private func start(delete task: DBTask) throws {
        try DeleteEventOperation(task, storage: storage, database: database, eventController: eventController)
            .perform()
            .subscribe({ [weak self] result in
                switch result {
                case .success(let deletedEvent): self?.removeDeletedEvent(deletedEvent, for: task)
                case .error: self?.retryTask(task: task)
                default: break
                }
                
                if let pending = self?.database.task.pending.count {
                    self?.updateState(with: pending)
                }
            }).disposed(by: disposeBag)
    }
    
    private func start(indicate task: DBTask) throws {
        try SendIndicationOperation(
            task,
            storage: storage,
            database: database,
            eventController: eventController).perform().subscribe({ [weak self] _ in
                self?.signalTaskQueueChange()
                
                if let pending = self?.database.task.pending.count {
                    self?.updateState(with: pending)
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK:
    // MARK: Database
    
    internal func removeDeletedEvent(_ deletedEvent: Event?=nil, for task: DBTask?=nil) {
        do {
            try ModifyDBEventOperation(deletedEvent, with: task, storage: storage, database: database).perform().subscribe({ [weak self] result in
                switch result {
                case .completed, .success: self?.signalTaskQueueChange()
                case .error(let error): Log.error(.database, "Failed to Delete/Save with: \(error)")
                }
                
                if let pending = self?.database.task.pending.count {
                    self?.updateState(with: pending)
                }
            }).disposed(by: disposeBag)
        } catch let error {
            Log.error(.database, "Failed to Delete/Save with: \(error)")
            
            updateState(with: database.task.pending.count)
        }
    }
    
    // MARK:
    // MARK: Private - Retry
    
    private func retryTask(task: DBTask) {
        task.beingProcessed = false
        task.retryCount += 1
        
        try? database.task.insert(task) // TODO Avoid going in to a very fast retry loop here. Need to somehow be able to delay tasks.
        
        if task.retryCount >= EventQueue.maximumRetries {
            Log.warn(.taskProcessor, "Task has reached max number of retries, id: \(task.uuid ?? 0)")
        }
        
        signalTaskQueueChange()
    }
    
    // MARK:
    // MARK: Private - Observer
    
    private func watchForNewMessages(newEvent: EventBase) {
        /* Determine if this is one of the messages we are waiting for. */
        var watcher: QueueObserver? = nil
        sendMessageWatchersCondition.lock()
        
        if let index = sendMessageWatchers.index(of: QueueObserver(conversation: newEvent.conversation, draftMessage: nil, sentMessageEventId: newEvent.id, handlerRef: nil)) {
            /* Get the watcher and remove the handler. */
            let watch = sendMessageWatchers.remove(at: index)
            
            if let handleRef = watch.handlerRef {
                watch.conversation.events.newEventReceived.removeHandler(handleRef)
            }
            
            watcher = watch
        }
        
        sendMessageWatchersCondition.unlock()
        
        /* If one of our messages was sent, do the necessary work to remove the draft and task. */
        if let newEvent = newEvent as? TextEvent, watcher != nil {
             newEvent.conversation.events.eventSent.emit(newEvent)
        }
    }
    
    // MARK:
    // MARK: State
    
    func updateState(with count: Int) {
        state.tryWithValue = count == 0 ? .inactive : .active(count)
    }
}

// MARK:
// MARK: Compare

/// :nodoc:
internal func ==(lhs: EventQueue.State, rhs: EventQueue.State) -> Bool {
    switch (lhs, rhs) {
    case (.active, .active): return true
    case (.inactive, .inactive): return true
    case (.active, _),
         (.inactive, _): return false
    }
}
