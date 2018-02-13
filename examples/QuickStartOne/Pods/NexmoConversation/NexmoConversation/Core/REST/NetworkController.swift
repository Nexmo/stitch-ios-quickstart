//
//  NetworkController.swift
//  NexmoConversation
//
//  Created by James Green on 26/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Network controller for managing HTTP and Web Socket
internal class NetworkController {
    
    /// Response source type
    ///
    /// - http: source from http
    /// - socket: source for web socket
    /// - push: source from push notification
    /// - other: custom source with path
    internal enum Source {
        case http
        case socket(event: String)
        case push
        case other(name: String)
    }
    
    // MARK:
    // MARK: Auth
    
    /// API token updater
    internal var token: String {
        didSet {
            HTTPManager.adapter = AuthorizationAdapter(with: token, sessionId: sessionId)
            socketService.token = token
        }
    }

    /// API session updater
    internal var sessionId: String {
        didSet {
            HTTPManager.adapter = AuthorizationAdapter(with: token, sessionId: sessionId)
        }
    }

    // MARK:
    // MARK: Networking
    
    /// HTTP manager
    private let HTTPManager: HTTPSessionManager
    
    /// Socket manager
    private let webSocketManager: WebSocketManager

    // MARK:
    // MARK: Queue
    
    /// parse responses
    internal let queue = DispatchQueue.parsering
    
    // MARK:
    // MARK: Service
    
    /// Service for Push Notification
    internal let pushNotificationService: PushNotificationService
    
    /// Service for IPS
    internal let ipsService: IPSService
    
    /// Service for Conversation
    internal let conversationService: ConversationService
    
    /// Service for Event
    internal let eventService: EventService
    
    /// Service for Account
    internal let accountService: AccountService
    
    /// Service for Membership
    internal let membershipService: MembershipService
    
    /// Service for Socket Subscriptions
    internal let subscriptionService: SubscriptionService
    
    /// Service for Socket Events
    internal let socketService: SocketService

    /// Service for Socket Events
    internal let mediaService: MediaService

    /// Service for RTC Events
    internal let rtcService: RTCService
    
    // MARK:
    // MARK: Status
    
    /// Socket status
    internal var socketState: Variable<WebSocketManager.State> { return webSocketManager.state }
    
    /// Listen for internal network error
    internal var networkError: Variable<NetworkErrorProtocol?> { return HTTPManager.errorListener }
    
    /// Network reachability status
    internal var networkState: Variable<ReachabilityManager.State> { return HTTPManager.reachabilityManager.state }
    
    // MARK:
    // MARK: Initializers
    
    internal init(token: String="", sessionId: String="") {
        self.token = token
        self.sessionId = sessionId
        
        HTTPManager = HTTPSessionManager(queue: queue)
        HTTPManager.adapter = AuthorizationAdapter(with: token)
        webSocketManager = WebSocketManager(queue: queue)
        
        subscriptionService = SubscriptionService(webSocketManager: webSocketManager)
        socketService = SocketService(webSocketManager: webSocketManager)
        
        ipsService = IPSService(manager: HTTPManager)
        membershipService = MembershipService(manager: HTTPManager)
        accountService = AccountService(manager: HTTPManager)
        eventService = EventService(manager: HTTPManager, ipsService: ipsService)
        conversationService = ConversationService(manager: HTTPManager)
        pushNotificationService = PushNotificationService(manager: HTTPManager)
        mediaService = MediaService(manager: HTTPManager)
        rtcService = RTCService(manager: HTTPManager)
    }
    
    // MARK:
    // MARK: Connection
    
    internal func connect() {
        webSocketManager.connect()
    }
    
    internal func disconnect() {
        webSocketManager.close()
    }
}
