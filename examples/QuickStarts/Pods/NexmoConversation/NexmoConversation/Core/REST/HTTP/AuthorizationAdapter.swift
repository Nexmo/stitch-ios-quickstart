//
//  AuthorizationAdapter.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 04/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Authorization request builder
internal struct AuthorizationAdapter: RequestAdapter {

    /// Session iD
    private let id: String?

    /// Authorization token
    private let token: String?
    
    // MARK:
    // MARK: Initializers
    
    internal init(with token: String?=nil, sessionId id: String?=nil) {
        self.id = id
        self.token = token
    }
    
    // MARK:
    // MARK: RequestAdapter
    
    internal func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let token = token, !token.isEmpty else { throw HTTPSessionManager.Errors.invalidToken }
        
        var urlRequest = urlRequest

        urlRequest.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: HTTPSessionManager.HeaderKeys.authorization.rawValue
        )

        urlRequest.setValue(id, forHTTPHeaderField: HTTPSessionManager.HeaderKeys.session.rawValue)
        
        return urlRequest
    }
}
