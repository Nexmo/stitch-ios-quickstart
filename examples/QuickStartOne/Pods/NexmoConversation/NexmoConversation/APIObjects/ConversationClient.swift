//
//  ConversationClient.swift
//  NexmoConversation
//
//  Created by James Green on 22/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Conversation Client main interface
@objc(NXMConversationClient)
@objcMembers
public class ConversationClient: NSObject {

    // MARK:
    // MARK: Typealias

    /// Callback for response of login
    public typealias LoginResponse = (LoginResult) -> Void

    // MARK:
    // MARK: Enum

    /// Enum
    ///
    /// - userNotInCorrectState: user is not in the correct state.
    /// - networking: a description of the network.
    /// - busy: the network is busy.
    /// - missingParameters: the method does not have all the required parameters
    /// - unknown: the error is unknown.
    internal enum Errors: Error, Equatable {
        case userNotInCorrectState
        case networking
        case busy
        case missingParameters
        case unknown(String?)
    }

    /// LoginResponse state
    ///
    /// - success: successful
    /// - failed: failed for unknown
    /// - invalidToken: token is invalid
    /// - sessionInvalid: session is invalid
    /// - expiredToken: token expired
    @objc(NXMLoginResult)
    public enum LoginResult: Int, Error {
        /// successful
        case success
        /// failed for unknown
        case failed
        /// token is invalid
        case invalidToken
        /// session is invalid
        case sessionInvalid
        /// token expired
        case expiredToken
    }

    /// Global state of client
    ///
    /// - disconnected: SDK is disconnected from all services and / or triggered on user logout, disconnection or as an initial, default, state.
    /// - connecting: SDK is requesting permission to reconnect.
    /// - connected: SDK is connected to all services
    /// - outOfSync: SDK is not synchronized yet.
    /// - synchronizing: SDK is synchronizing with current progress state.
    /// - synchronized: SDK is synchronized with all services and ready now.
    public enum State: Equatable {
        /// SDK is disconnected from all services and / or triggered on user logout, disconnection or as an initial, default, state.
        case disconnected
        /// SDK is requesting permission to reconnect.
        case connecting
        /// SDK is connected to all services
        case connected
        /// SDK is not synchronized yet.
        case outOfSync
        /// SDK is synchronizing with current progress state.
        case synchronizing(SynchronizingState)
        /// SDK is synchronized with all services and ready now.
        case synchronized

        // MARK:
        // MARK: String

        internal var stringValue: String {
            switch self {
            case .disconnected: return "disconnected"
            case .connecting: return "connecting"
            case .connected: return "connected"
            case .outOfSync: return "outOfSync"
            case .synchronizing(let state): return state.rawValue
            case .synchronized: return "synchronized"
            }
        }
    }

    // MARK:
    // MARK: Shared

    /// A static instance (singleton) to access the ConversationClient.
    public static let instance: ConversationClient = ConversationClient()

    // MARK:
    // MARK: Configurations

    /**
     Client configuration
     @warning: can only be set before calling ConversationClient.instance or ConversationClient()
     */
    public static var configuration: Configuration = Configuration.default

    // MARK:
    // MARK: Properties

    /// Controller to handle user account task
    public let account: AccountController

    /// Controller to handle conversation request for network, cache, database
    public let conversation: ConversationController

    /// a static constant of type Storage
    internal let storage: Storage
    /// a static constant of type SyncManager
    internal let syncManager: SyncManager

    /// Login callback, set to nil after call
    internal(set) var authenticationCompletion: LoginResponse?

    /// Controller to listen to lifecycle actions from application
    public let appLifecycle: AppLifecycleController

    /// Controller for handling network events
    internal let networkController: NetworkController

    /// Controller to handle events from a conversation
    internal let eventController: EventController

    /// Controller for handling socket events
    internal let socketController: SocketController

    /// Controller to handle user membership status
    internal let membershipController: MembershipController

    /// Controller to handle assets
    internal let assetController: AssetController

    /// Media Controller
    public let media: MediaController
    
    // MARK:
    // MARK: Properties - Observable

    /// State of client
    public let state = MutableObservable(RxSwift.Variable<State>(.disconnected))

    /// Internal error
    public var unhandledError: NexmoConversation.Observable<NetworkErrorProtocol> {
        // Filter: inital value is set as nil, avoid unnecessary reports
        return networkController
            .networkError
            .asObservable()
            .filter { $0 != nil }
            .unwrap()
            .share()
            .wrap
    }

    // MARK:
    // MARK: Disposable

    /// Shared disposable bag
    internal let disposeBag = DisposeBag()

    // MARK:
    // MARK: Initializers

    @discardableResult
    private override init() {
        ConversationClient.preSetup()
        
        networkController = NetworkController()
        account = AccountController(network: networkController)
        media = MediaController(network: networkController)
        conversation = ConversationController(network: networkController, account: account, rtc: media)
        membershipController = MembershipController(network: networkController)
        assetController = AssetController(network: networkController)

        storage = Storage(account: account,
                          conversation: conversation,
                          membershipController: membershipController
        )

        eventController = EventController(network: networkController, storage: storage)

        syncManager = SyncManager(
            conversation: conversation,
            account: account,
            eventController: eventController,
            membershipController: membershipController,
            storage: storage,
            databaseManager: storage.databaseManager,
            eventQueue: eventController.queue,
            asset: assetController
        )

        socketController = SocketController(
            socketService: networkController.socketService,
            subscriptionService: networkController.subscriptionService
        )

        appLifecycle = AppLifecycleController(networkController: networkController)
        
        account.storage = storage
        storage.eventController = eventController
        storage.eventQueue = eventController.queue
        conversation.conversations.storage = storage
        conversation.syncManager = syncManager
        media.conversationController = conversation
        super.init()

        setup()
    }

    // MARK:
    // MARK: Private - Setup

    /// Make sure setup is the first thing called
    private static func preSetup() {
        _ = ConversationClient.configuration
    }
    
    private func setup() {
        setupApplicationBinding()
        setupClientBinding()
        setupEventBinding()
        setupAdditionalBinding()
        setupFeatureToggle()
    }

    private func setupClientBinding() {
        // SKIP: inital state is .disconnected, to avoid unnecessary side effects
        networkController.socketState.asDriver().asObservable().skip(1).subscribe(onNext: {
            switch $0 {
            case .connecting:
                self.state.subject.tryWithValue = .connecting
            case .authentication:
                self.state.subject.tryWithValue = .connecting
            case .connected(let session):
                self.state.subject.tryWithValue = .connected
                self.account.userId = session.userId
                self.networkController.sessionId = session.id
                self.account.state.subject.value = .loggedIn(session)

                self.syncManager.start()
                self.eventController.queue.start()

                DispatchQueue.main.async {
                    self.authenticationCompletion?(.success)
                    self.authenticationCompletion = nil
                }
            case .notConnected(let reason):
                self.state.subject.tryWithValue = .disconnected

                DispatchQueue.main.async {
                    switch reason {
                    case .invalidToken:
                        self.authenticationCompletion?(.invalidToken)
                        self.logout()
                    case .sessionInvalid:
                        self.authenticationCompletion?(.sessionInvalid)
                        self.logout()
                    case .expiredToken:
                        self.authenticationCompletion?(.expiredToken)
                        self.logout()
                    case .timeout, .connectionLost, .unknown:
                        self.authenticationCompletion?(.failed)
                    }

                    self.authenticationCompletion = nil
                }
            case .disconnected:
                self.state.subject.tryWithValue = .disconnected
            }
        }).disposed(by: disposeBag)

        // SKIP: inital state inactive, which at this layer means is synchronized
        syncManager.state.asDriver().asObservable().skip(1).subscribe(onNext: { state in
            switch state {
            case .inactive: self.state.subject.tryWithValue = .synchronized
            case .failed: self.state.subject.tryWithValue = .outOfSync
            case .active(let state) where !(self.state.value == .synchronized):
                self.state.subject.tryWithValue = .synchronizing(state)
            default: break
            }
        }).disposed(by: disposeBag)
    }

    private func setupEventBinding() {
        networkController.subscriptionService.events.asObservable()
            .unwrap()
            .flatMap { self.syncManager.receivedEvent($0) }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func setupApplicationBinding() {
        appLifecycle.applicationState
            .subscribeOnBackground()
            .flatMap { [unowned self] state -> RxSwift.Observable<Void> in
                switch state {
                case .active where ConversationClient.configuration.autoReconnect: return self.login().rx.catchError { _ in RxSwift.Observable<Void>.just(()) }
                case .inactive: self.disconnect()
                default: break
                }
                
                return RxSwift.Observable<Void>.just(())
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        appLifecycle.receiveRemoteNotification
            .rx
            .subscribeOnBackground()
            .flatMap { notification -> RxSwift.Observable<Event> in // convert the received notification into an Event object
                guard let rawtype = notification.payload["type"] as? String,
                    let type = Event.EventType(rawValue: rawtype),
                    let event = try? Event(type: type, json: notification.payload) else {
                    return RxSwift.Observable<Event>.never()
                }
                
                return RxSwift.Observable<Event>.just(event)
            }
            .flatMap { return self.syncManager.receivedEvent($0) } // process the Event object by passing it to the SyncManager
            .flatMap { event, conversation in // observe for conversation changes which get 'reported' when SyncManager has finished processing conversation events
                return self.conversation.conversations
                    .asObservable
                    .rx
                    .filter { // pass on changes for conversation with uuid equal to cid in the event
                        switch $0 {
                        case .inserted(let conversation, _): return conversation.uuid == event.cid
                        case .updated(let conversation): return conversation.uuid == event.cid
                        case .deleted(let conversation): return conversation.uuid == event.cid
                        }
                    }
            }.subscribe(onNext: { [unowned self] change in // if we have a conversation change to 'report', update notificationVariable for its listeners to handle
                self.appLifecycle.notificationVariable.value = .conversation(change)
            }).disposed(by: disposeBag)

        let isLoggedIn: RxSwift.Observable<Data?> = account.state
            .rx
            .filter { state in
                guard case .loggedIn = state else { return false }
                return true
            }
            .map { _ in nil }

        let hasDeviceToken: RxSwift.Observable<Data?> = appLifecycle.push.state
            .rx
            .observeOnBackground()
            .map { [unowned self] state -> Data? in
                guard case PushNotificationController.State.registeredWithDeviceToken(let token) = state else {
                    self.appLifecycle.push.unregisterForPushNotifications()
                    return nil
                }

                let deviceToken = token.hexString
                Log.info(.other, "appLifecycle registered with token \(deviceToken)")

                return token
            }

        RxSwift.Observable<Data?>.zip([isLoggedIn, hasDeviceToken])
            .map { $0.flatMap { $0 }.first }
            .unwrap()
            .subscribeOnBackground()
            .flatMap { [unowned self] deviceToken in
                self.appLifecycle.push.update(
                    deviceToken: deviceToken,
                    deviceId: UIDevice.current.identifierForVendor?.uuidString
                ).rx
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func setupAdditionalBinding() {
        // Hack to fix issue where login not been called due to delayed binding of UIApplication
        RxSwift.Observable<Int>.timer(0.5, scheduler: ConcurrentDispatchQueueScheduler(qos: .utility))
            .filter { _ in self.state.value == .disconnected && ConversationClient.configuration.autoReconnect }
            .flatMap { _ in self.login().rx.asDriver(onErrorJustReturn: ()) }
            .subscribeOnBackground()
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func setupReachabilityBinding() {
        networkController.networkState.asObservable()
            .scan((.failed, networkController.networkState.value)) { (lastEvent, newElement) -> (ReachabilityManager.State, ReachabilityManager.State) in
                let (_, oldElement) = lastEvent

                return (oldElement, newElement)
            }
            .skip(1) // SKIP: inital value is both set as (.disconnect, .disconnect) when the SDK starts up
            .subscribe(onNext: { [unowned self] old, new in
                // see if we need to trigger a reconnect
                if old == .notReachable && new.isReachable {
                    self.reconnect()
                }
            }).disposed(by: disposeBag)
    }

    private func setupFeatureToggle() {
        let configuration = ConversationClient.configuration

        if configuration.autoReconnect {
            setupReachabilityBinding()
        }

        if configuration.clearAllData {
            try? storage.reset()
        }
    }

    // MARK:
    // MARK: Private - Client

    private func reconnect() {
        switch networkController.socketState.value {
        case .notConnected: networkController.connect()
        default: break
        }

        switch syncManager.state.value {
        case .inactive, .failed:
            self.state.subject.tryWithValue = .outOfSync

            eventController.queue.reconnect()
            syncManager.reconnect()
        default: break
        }
    }

    // MARK:
    // MARK: Client

    /// Close this library, and free all its resources. It cannot be used again after calling close().
    public func disconnect() {
        eventController.queue.close()
        syncManager.close()
        networkController.disconnect()
        storage.clear() // clear memory cache
    }
}

// MARK:
// MARK: Compare

/// Compare state
///
/// - Parameters:
///   - lhs: lhs state
///   - rhs: rhs state
/// - Returns: result of comparison
/// :nodoc:
public func ==(lhs: ConversationClient.State, rhs: ConversationClient.State) -> Bool {
    switch (lhs, rhs) {
    case (.disconnected, .disconnected): return true
    case (.connecting, .connecting): return true
    case (.connected, .connected): return true
    case (.outOfSync, .outOfSync): return true
    case (.synchronizing(let lhs), .synchronizing(let rhs)):
        switch (lhs, rhs) {
        case (.conversations, .conversations): return true
        case (.events, .events): return true
        case (.members, .members): return true
        case (.users, .users): return true
        case (.receipts, .receipts): return true
        case (.tasks, .tasks): return true
        case (.conversations, _),
             (.events, _),
             (.members, _),
             (.users, _),
             (.receipts, _),
             (.tasks, _): return false
        }
    case (.synchronized, .synchronized): return true
    case (.disconnected, _),
         (.connecting, _),
         (.connected, _),
         (.outOfSync, _),
         (.synchronizing, _),
         (.synchronized, _): return false
    }
}

/// Compare errors
/// :nodoc:
internal func ==(lhs: ConversationClient.Errors, rhs: ConversationClient.Errors) -> Bool {
    switch (lhs, rhs) {
    case (.userNotInCorrectState, .userNotInCorrectState): return true
    case (.networking, .networking): return true
    case (.busy, .busy): return true
    case (.missingParameters, .missingParameters): return true
    case (.unknown, .unknown): return true
    case (.userNotInCorrectState, _),
         (.networking, _),
         (.busy, _),
         (.missingParameters, _),
         (.unknown, _): return false
    }
}
