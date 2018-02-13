//
//  Queue.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 11/05/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Protocol to handle common queue states
internal protocol Queue {
    
    associatedtype QueueState
    
    /// State of queue
    var state: Variable<QueueState> { get set }
    
    static var maximumParallelTasks: Int { get }
    static var maximumRetries: Int { get }
}
