//
//  EventService.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 04/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Event service to handle all network request
internal struct EventService {
    
    /// Network manager
    private let manager: HTTPSessionManager
    
    /// Image process services
    private let ipsService: IPSService
    
    // MARK:
    // MARK: Initializers
    
    internal init(manager: HTTPSessionManager, ipsService: IPSService) {
        self.manager = manager
        self.ipsService = ipsService
    }
    
    // MARK:
    // MARK: Send
    
    /// Send a event to an conversation with event model
    ///
    /// - parameter event: event model
    /// - parameter success: success with event response model
    /// - parameter failure: failure
    ///
    /// - returns: request
    @discardableResult
    internal func send(event: SendEvent, success: @escaping (EventResponse?) -> Void, failure: @escaping (Error) -> Void) -> Request {
        return Request(with: manager
            .request(EventRouter.send(event: event))
            .validateAndReportError(to: manager)
            .responseData(queue: manager.queue, completionHandler: {
                switch $0.result {
                case .failure(let error): failure((try? NetworkError(from: $0)) ?? error)
                case .success(let response): success(try? JSONDecoder().decode(EventResponse.self, from: response))
                }
            })
        )
    }
    
    /// Convenience method for uploading image to IPS and send the image event
    ///
    /// - parameter image:          image data and parameter
    /// - parameter conversationId: conversation Id
    /// - parameter fromId:         member Id
    /// - parameter success:        success callback
    /// - parameter failure:        failed callback
    internal func upload(
        image: IPSService.UploadImageParameter,
        conversationId: String, 
        fromId: String,
        tid: String,
        success: @escaping (EventResponse?) -> Void,
        failure: @escaping (Error) -> Void,
        progress: @escaping (Request) -> Void) {
        ipsService.upload(image: image, success: { model in
            let body = model.json
            let event = SendEvent(
                conversationId: conversationId,
                from: fromId,
                representations: body,
                tid: tid
            )
            
            self.send(event: event, success: { success($0) }, failure: { failure($0) })
        }, failure: { error in
            failure(error)
        }, progress: progress)
    }
    
    // MARK:
    // MARK: Retrieve
    
    /// Retrieve all events for a conversation
    ///
    /// - parameter for: conversation uuid
    /// - parameter with: range
    /// - parameter success: success callback
    /// - parameter failure: failure callback
    ///
    /// - returns: request
    @discardableResult
    internal func retrieve(for uuid: String, with range: Range<Int>, success: @escaping ([Event]) -> Void, failure: @escaping (Error) -> Void) -> DataRequest {
        return manager
            .request(EventRouter.events(conversationUuid: uuid, range: range))
            .validateAndReportError(to: manager)
            .responseJSON(queue: manager.queue, completionHandler: {
                switch $0.result {
                case .failure(let error):
                    failure((try? NetworkError(from: $0)) ?? error)
                case .success(let response):
                    guard let json = response as? [Parameters] else {
                        return failure(JSONError.malformedJSON)
                    }

                    let models = json.flatMap { try? Event(conversationUuid: uuid, json: $0) }

                    success(models)
                }
            })
    }
    
    // MARK:
    // MARK: Delete
    
    /// Delete event from a conversation
    ///
    /// - Parameters:
    ///   - eventId: event id
    ///   - for: member id
    ///   - uuid: conversation id
    ///   - success: success
    ///   - failure: failure
    /// - Returns: request
    @discardableResult
    internal func delete(_ eventId: String, for memberId: String, in uuid: String, success: @escaping (Event) -> Void, failure: @escaping (Error) -> Void) -> DataRequest {
        return manager
            .request(EventRouter.delete(eventId: eventId, conversationUuid: uuid, memberId: memberId))
            .validateAndReportError(to: manager)
            .responseJSON(queue: manager.queue, completionHandler: {
                switch $0.result {
                case .failure(let error):
                    failure((try? NetworkError(from: $0)) ?? error)
                case .success:
                    // build event to pass back to listener
                    let model = Event(conversationUuid: uuid, type: .eventDelete, eventId: eventId, memberId: memberId)
                    
                    success(model)
                }
            }
        )
    }
}
