//
//  RTCService.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// RTC service
internal struct RTCService {

    /// Create a session to perform a request
    internal typealias Session = (conversationId: String, RTCId: String)

    /// Errors
    ///
    /// - invalidResponseFromBackend:
    internal enum Errors: Error {
        case unknown
    }

    /// Network manager
    private let manager: HTTPSessionManager

    // MARK:
    // MARK: Initializers

    internal init(manager: HTTPSessionManager) {
        self.manager = manager
    }

    // MARK:
    // MARK: RTC

    /// Create new RTC session
    ///
    /// - Parameters:
    ///   - conversationId: conversation
    ///   - model: model info
    ///   - success: success
    ///   - failure: failure
    /// - Returns: request
    @discardableResult
    internal func new(_ conversationId: String, from model: New, success: @escaping (RTC.Response) -> Void, failure: @escaping (Error) -> Void) -> DataRequest {
        return manager
            .request(RTCRouter.new(conversationId: conversationId, from: model))
            .validateAndReportError(to: manager)
            .responseData(queue: manager.queue, completionHandler: {
                switch $0.result {
                case .failure(let error):
                    failure((try? NetworkError(from: $0)) ?? error)
                case .success(let response):
                    guard let model = try? JSONDecoder().decode(RTC.Response.self, from: response) else {
                        return failure(JSONError.malformedJSON)
                    }

                    success(model)
                }
            }
        )
    }

    /// Terminate a RTC session
    ///
    /// - Parameters:
    ///   - session: session info
    ///   - memberId: memberId
    ///   - success: success
    ///   - failure: failure
    /// - Returns: request
    @discardableResult
    internal func terminate(_ session: Session, from memberId: String, success: @escaping (()) -> Void, failure: @escaping (Error) -> Void) -> DataRequest {
        return manager
            .request(RTCRouter.terminate(conversationId: session.conversationId, RTCId: session.RTCId, memberId: memberId))
            .validateAndReportError(to: manager)
            .response(completionHandler: {
                guard $0.error == nil else { return failure(NetworkError(from: $0)) }

                success(())
            }
        )
    }

    /// Send a event to an conversation with event model
    ///
    /// - parameter event: event model
    /// - parameter success: success with 200 OK
    /// - parameter failure: failure
    ///
    /// - returns: request
    @discardableResult
    internal func send(event: RTC.Request, success: @escaping () -> Void, failure: @escaping (Error) -> Void) -> Request {
        return Request(with: manager
            .request(RTCRouter.send(event: event))
            .validateAndReportError(to: manager)
            .responseJSON(queue: manager.queue, completionHandler: {
                switch $0.result {
                case .failure(let error): failure((try? NetworkError(from: $0)) ?? error)
                case .success: success()
                }
            })
        )
    }
}
