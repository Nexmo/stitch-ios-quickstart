//  Conversation.swift
//  NexmoConversation
//
//  Created by James Green on 26/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Conversation Facade Object
@objc(NXMConversation)
public class Conversation: NSObject {
    
    // MARK:
    // MARK: Enum
    
    /// Reserved Prefixes, avoid using to stop strange behaviour
    ///
    /// - call: Intended for Calling 
    internal enum ReservedPrefix: String {
        case call = "CALL_"
    }
    
    /// Invitation media type
    ///
    /// - audio: audio invite, Default: @muted, @earmuffed set to false
    public enum Media {
        /// audio invite, Default: @muted, @earmuffed set to false
        case audio(muted: Bool, earmuffed: Bool)
    }
    
    /// Error
    ///
    /// - eventBodyIsEmpty: event could not be found in storage or database
    /// - cannotProcessRequest: cannot process request
    /// - memberNotFound: member not found in cache/db
    /// - usernameNotFound: username not found
    public enum Errors: Error, Equatable {
        /// event could not be found in storage or database
        case eventBodyIsEmpty
        /// cannot process request
        case cannotProcessRequest
        /// member not found in cache/db
        case memberNotFound
        /// username not found
        case usernameNotFound
    }
    
    // MARK:
    // MARK: Properties
    
    internal var data: DBConversation

    /// UUID identifying this conversation.
    public var uuid: String { return data.rest.uuid }
    
    /// Conversation name
    public var name: String {
        if !data.rest.displayName.isEmpty {
            return data.rest.displayName
        } else {
            return data.rest.name
        }
    }
    
    /**
     An array of all of the users in the conversation.
     
     ```
     var users:[Users] = conversation.members.users
     ```
     
     */
    public var users: [User] { return members.users }
    
    /// Last event number 
    public var lastSequence: Int { return data.rest.sequenceNumber }
    
    /**
     A collection of all of the members in the conversation.
     
     ```
     var members: NexmoConversation.LazyCollection<Member>  = conversation.allMembers
     ```
     
     */
    public let members: MemberCollection
    
    /// All events in this conversation.
    public let events: EventCollection
    
    /**
     The state of the user in this conversation.  Can be any of the states in Member.State
     
     ```
     var state: Member.State = conversation.state
     ```
     
     */
    public var state: MemberModel.State {
        guard let user = account.user, let membership = membershipForUser(user: user).last else {
            return .unknown
        }
        return membership.state
    }
    
    /**
     Date conversation was created
     */
    public var creationDate: Date { return data.rest.created }

    // this method will find the last of our joined members, and use the last unjoined member if no joined member exists
    // Hopefully user will only have one joined member!
    internal var ourMemberRecord: Member? {
        guard let me = account.user else { return nil }
        
        let members = membershipForUser(user: me)
        let membership1 = members.filter { $0.state == .joined }.last
        let membership2 = members.last
        
        return membership1 ?? membership2
    }
    
    internal var ourMemberRecords: [Member] {
        if let me = self.account.user {
            return membershipForUser(user: me)
        }
        
        return []
    }
    
    private let eventQueue: EventQueue
    private let eventController: EventController
    internal let account: AccountController
    internal let controller: ConversationController
    internal let membershipController: MembershipController
    private let databaseManager: DatabaseManager

    /// Media
    public private(set) lazy var media: NexmoConversation.Media = { return NexmoConversation.Media(with: self) }()

    /// Rx
    internal let disposeBag = DisposeBag()
    
    // MARK:
    // MARK: Properties - Observable
    
    /// Signal for when new member is added to the conversation
    public let newMember = Signal<Member>()
    
    /// Signal for when a member left the conversation
    public let memberLeft = Signal<Member>()
    
    /// Signal for when a member joined the conversation
    public let memberJoined = Signal<Member>()

    /// Signal for when a member is invited to the conversation
    public let memberInvited = Signal<Member>()
  
    /// Signal for when the members in this conversation change
    public let membersChanged = Signal<Void>()

    // MARK:
    // MARK: NSObject
    
    /// Hashable
    /// :nodoc:
    public override var hashValue: Int { return data.rest.uuid.hashValue }
    
    /// Description
    /// :nodoc:
    public override var description: String { return "uuid:" + data.rest.uuid + ", " + self.name }
    
    // MARK:
    // MARK: Initializers
    
    internal init(_ conversation: DBConversation,
                  eventController: EventController,
                  databaseManager: DatabaseManager,
                  eventQueue: EventQueue,
                  account: AccountController,
                  conversationController: ConversationController,
                  membershipController: MembershipController) {
        data = conversation
        members = MemberCollection(conversationUuid: self.data.rest.uuid, databaseManager: databaseManager)
        events = EventCollection(conversationUuid: self.data.rest.uuid, databaseManager: databaseManager)
        controller = conversationController
        self.eventController = eventController
        self.databaseManager = databaseManager
        self.eventQueue = eventQueue
        self.account = account
        self.membershipController = membershipController
        
        super.init()
        
        setup()
    }
    
    internal init(_ conversation: ConversationModel,
                  eventController: EventController,
                  databaseManager: DatabaseManager,
                  eventQueue: EventQueue,
                  account: AccountController,
                  conversationController: ConversationController,
                  membershipController: MembershipController) {
        data = DBConversation(conversation: conversation)
        members = MemberCollection(conversationUuid: self.data.rest.uuid, databaseManager: databaseManager)
        events = EventCollection(conversationUuid: self.data.rest.uuid, databaseManager: databaseManager)
        controller = conversationController
        self.eventController = eventController
        self.databaseManager = databaseManager
        self.eventQueue = eventQueue
        self.account = account
        self.membershipController = membershipController
        
        super.init()
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {

    }
    
    // MARK:
    // MARK: Event
    
    /// Send text event
    ///
    /// - Parameter text: text
    /// - throws: error if task cannot be added to queue or event is empty
    @objc(sendText:error:)
    public func send(_ text: String) throws {
        guard text.isEmpty == false else { throw Errors.eventBodyIsEmpty }
        guard let member = ourMemberRecord else { throw Errors.cannotProcessRequest }

        let event = TextEvent(conversationUuid: uuid, member: member, isDraft: true, distribution: members.uuids, seen: true, text: text)
                
        try send(event)
    }
    
    /// Send image event
    ///
    /// - Parameter image: raw image, use UIImagePNGRepresentation or UIImageJPEGRepresentation 
    /// - throws: error if task cannot be added to queue or event is empty
    @objc(sendImage:error:)
    public func send(_ image: Data) throws {
        guard let member = ourMemberRecord else { throw Errors.cannotProcessRequest }

        let key = String(arc4random())
        let path = eventController.storage.fileCache.set(key: key, value: image)
        let image = Event.Body.Image(id: key, path: path, size: image.count)
        let event = Event(cid: uuid, type: .image, memberId: member.data.rest.id, body: image.json)
        let imageEvent = ImageEvent(conversationUuid: uuid, event: event, seen: true, isDraft: true)
        
        try send(imageEvent)
    }
    
    /// Send event
    ///
    /// - parameter event: event
    ///
    /// - throws: error if task cannot be added to queue or event is empty
    public func send(_ event: TextEvent) throws {
        try eventQueue.add(.send, with: event)
    }
    
    /// Delete event
    ///
    /// - Parameter event: event to delete
    /// - Returns: if event is scheduled to be deleted
    @discardableResult
    public func delete(_ event: TextEvent) -> Bool {
        guard event.from.isMe else { return false }
        
        do {
            try eventQueue.add(.delete, with: event)
            
            return true
        } catch {
            return false
        }
    }
    
    // MARK:
    // MARK: Membership
    
    /// Memberships for User
    ///
    /// A user can have more than one membership in a conversation if they have left a conversation and then rejoined.
    ///
    /// - parameter user: the user whose memberships you want
    ///
    /// - returns: An array of members for this user in this conversation
    public func membershipForUser(user: User) -> [Member] {
        return members.membershipForUser(user: user)
    }
    
    /// Join this conversatation
    ///
    /// - returns: an operation which joins the user to the conversation
    public func join() -> NexmoConversation.Observable<Void> {
        guard case .loggedIn(let session) = account.state.value else {
            return RxSwift.Observable<Void>
                .error(ConversationClient.Errors.userNotInCorrectState)
                .wrap
        }

        return controller.join(ConversationController.JoinConversation(userId: session.userId, memberId: ourMemberRecord?.uuid), forUUID: uuid)
            .do(onError: { [weak self] _ in self?.members.refresh() })
            .flatMap { _ in RxSwift.Observable<Void>.just(()) }
            .observeOnMainThread()
            .wrap
    }
    
    /// Leave this conversation
    ///
    /// - returns: an operation which removes the user from the conversation and can be used to cancel the request
    public func leave() -> NexmoConversation.Observable<Void> {
        guard let member = ourMemberRecord else {
            return RxSwift.Observable.error(Errors.memberNotFound).wrap
        }
            
        return member.kick()
    }
    
    /// Invite user to this conversation
    ///
    /// - Parameters:
    ///   - username: username
    ///   - userId: userId optional
    ///   - media: media type i.e audio 
    /// - Returns: Completion of inviting a member to the conversation
    public func invite(_ username: String, userId: String?=nil, with media: Media?=nil) -> NexmoConversation.Observable<Void?> {
        return membershipController.invite(userId: userId, username: username, for: uuid, with: media)
            .observeOnMainThread()
            .wrap
    }
    
    // MARK:
    // MARK: Indicator
    
    /// Indicate user is trying
    ///
    /// - returns: result of request was sent
    @discardableResult
    public func startTyping() -> Bool {
        return setTypingStatus(true)
    }
    
    /// Indicate user has stopped trying
    ///
    /// - returns: result of request was sent
    @discardableResult
    public func stopTyping() -> Bool {
        return setTypingStatus(false)
    }
    
    /// Start/Stop typing
    ///
    /// - returns: result of request was sent
    @discardableResult
    private func setTypingStatus(_ isTyping: Bool) -> Bool {
        guard let memberId = ourMemberRecord?.uuid else { return false }
        let event = SendEvent(conversationId: uuid, from: memberId, isTyping: isTyping)
        
        eventController.send(event, progress: { _ in })
            .subscribe()
            .disposed(by: disposeBag)
        
        return true
    }
    
    // MARK:
    // MARK: Refresh

    internal func refreshMembers() {
        members.refresh()
    }
    
    internal func refreshEvents() {
        events.refresh()
    }
    
    /// Mark as dirty
    public func markIncomplete() {
        data.dataIncomplete = true
    }
    
    /// Mark as dirty
    public func markRequiresSync() {
        data.requiresSync = true
    }
}

// MARK:
// MARK: Compare

/// Compare wherever conversation is the same
///
/// - Parameters:
///   - lhs: conversation
///   - rhs: conversation
/// - Returns: result
/// :nodoc:
public func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.data.rest.uuid == rhs.data.rest.uuid
}

/// Compare Errors types
/// :nodoc:
public func ==(lhs: Conversation.Errors, rhs: Conversation.Errors) -> Bool {
    switch (lhs, rhs) {
    case (.eventBodyIsEmpty, .eventBodyIsEmpty): return true
    case (.cannotProcessRequest, .cannotProcessRequest): return true
    case (.memberNotFound, .memberNotFound): return true
    case (.usernameNotFound, .usernameNotFound): return true
    case (.memberNotFound, _),
         (.eventBodyIsEmpty, _),
         (.usernameNotFound, _),
         (.cannotProcessRequest, _): return false
    }
}
