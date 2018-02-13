//
//  RTCRouter.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Router for RTC endpoints
internal enum RTCRouter: URLRequestConvertible {

    /// API base url
    private static let baseURL = BaseURL.rest

    /// create a new call
    case new(conversationId: String, from: RTCService.New)

    /// terminate call
    case terminate(conversationId: String, RTCId: String, memberId: String)

    /// Send a rtc event
    case send(event: RTC.Request)

    // MARK:
    // MARK: Request

    private var method: HTTPMethod {
        switch self {
        case .new: return .post
        case .terminate: return .delete
        case .send: return .post
        }
    }

    private var path: String {
        switch self {
        case .new(let conversationId, _): return "/conversations/\(conversationId)/rtc"
        case .terminate(let conversationId, let RTCId, _): return "/conversations/\(conversationId)/rtc/\(RTCId)"
        case .send(let event): return "/conversations/\(event.conversationId)/events"
        }
    }

    // MARK:
    // MARK: URLRequestConvertible

    /// Build request
    internal func asURLRequest() throws -> URLRequest {
        let url = try type(of: self).baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
        case .new(_, let model):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: model.toJSON())
        case .terminate(_, _, let memberId):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: ["from": memberId])
        case .send(let event):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: event.toJSON())
        }

        return urlRequest
    }
}
