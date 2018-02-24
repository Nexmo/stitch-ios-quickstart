//
//  DownloadQueue.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 18/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

internal struct DownloadQueue: Queue {

    internal typealias QueueState = State

    // MARK:
    // MARK: Enum

    /// Queue state
    ///
    /// - active: Queue has active jobs
    /// - inactive: Queue is ready to be used
    internal enum State: Equatable {
        case active(Int)
        case inactive
    }

    /// State of queue
    internal var state: RxSwift.Variable<State> = RxSwift.Variable<State>(.inactive)

    internal static var maximumParallelTasks: Int { return 3 }
    internal static var maximumRetries: Int { return 3 }

    internal let queue: OperationQueueScheduler = {
        let queue = OperationQueue()
        queue.name = String(describing: DownloadQueue.self)
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = maximumParallelTasks

        return OperationQueueScheduler(operationQueue: queue)
    }()

    private let disposeBag = DisposeBag()

    // MARK:
    // MARK: Initializers

    internal init() {
        setup()
    }

    // MARK:
    // MARK: Setup

    private func setup() {
        queue.operationQueue.rx.observe(Int.self, #keyPath(OperationQueue.operationCount))
            .unwrap()
            .map { count -> State in
                switch count {
                case 0: return .inactive
                default: return .active(count)
                }
            }
            .bind(to: state)
            .disposed(by: disposeBag)
    }
}

// MARK:
// MARK: Compare

/// :nodoc:
internal func ==(lhs: DownloadQueue.State, rhs: DownloadQueue.State) -> Bool {
    switch (lhs, rhs) {
    case (.active, .active): return true
    case (.inactive, .inactive): return true
    case (.active, _),
         (.inactive, _): return false
    }
}
