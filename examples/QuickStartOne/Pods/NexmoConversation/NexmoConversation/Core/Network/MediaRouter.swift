//
//  MediaRouter.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 18/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Router for media endpoints
internal enum MediaRouter: URLRequestConvertible {

    /// fetch asset
    case download(url: String)

    // MARK:
    // MARK: Request

    private var method: HTTPMethod {
        switch self {
        case .download: return .get
        }
    }

    private var path: String {
        switch self {
        case .download: return ""
        }
    }

    // MARK:
    // MARK: URLRequestConvertible

    /// Build request
    internal func asURLRequest() throws -> URLRequest {
        switch self {
        case .download(let url):
            var urlRequest = URLRequest(url: try url.asURL())
            urlRequest.httpMethod = method.rawValue

            return try JSONEncoding.default.encode(urlRequest)
        }
    }
}
