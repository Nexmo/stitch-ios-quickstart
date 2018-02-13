//
//  ReachabilityManager.swift
//  NexmoConversation
//
//  Created by paul calver on 31/07/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

internal class ReachabilityManager: ReachabilityManagerProtocol {

    internal enum State: Equatable {

        // MARK:
        // MARK: Enum

        internal enum ConnectionType: Equatable {
            case wifi
            case data
        }

        case failed
        case notReachable
        case reachable(ConnectionType)

        // MARK:
        // MARK: Helper

        internal var isReachable: Bool {
            switch self {
            case .failed, .notReachable: return false
            case .reachable: return true
            }
        }
    }

    /// Network reachability
    internal let networkReachability = NetworkReachabilityManager()
    
    /// State of network reachability
    internal var state: Variable<State> = Variable<State>(.failed)
    
    // MARK:
    // MARK: Initializers

    internal init() {
        setup()
    }

    // MARK:
    // MARK: Setup

    private func setup() {
        guard let networkReachability = networkReachability else { return }

        // begin listening to network reachability
        networkReachability.startListening()

        networkReachability.listener = { [weak self] _ in
            if self?.networkReachability?.isReachable ?? false {
                if self?.networkReachability?.isReachableOnEthernetOrWiFi ?? false {
                    self?.updateState(with: .reachable(.wifi))
                } else {
                    self?.updateState(with: .reachable(.data))
                }
            } else {
                self?.updateState(with: .notReachable)
            }
        }
    }
}

// MARK:
// MARK: Compare

/// :nodoc:
internal func ==(lhs: ReachabilityManager.State.ConnectionType, rhs: ReachabilityManager.State.ConnectionType) -> Bool {
    switch (lhs, rhs) {
    case (.wifi, .wifi): return true
    case (.data, .data): return true
    case (.wifi, _),
         (.data, _): return false
    }
}

/// :nodoc:
internal func ==(lhs: ReachabilityManager.State, rhs: ReachabilityManager.State) -> Bool {
    switch (lhs, rhs) {
    case (.failed, .failed): return true
    case (.notReachable, .notReachable): return true
    case (.reachable(let l), .reachable(let r)): return l == r
    case (.failed, _),
         (.notReachable, _),
         (.reachable, _): return false
    }
}
