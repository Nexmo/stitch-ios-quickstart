//
//  MembershipRouter.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Router for membership endpoints
internal enum MembershipRouter: URLRequestConvertible {
    
    /// API base url
    private static let baseURL = BaseURL.rest
    
    /// Invite user to a conversation
    case invite(username: String, conversationId: String)

    /// Invite user to a conversation with audio support
    case inviteWithAudio(userId: String, username: String, conversationId: String, muted: Bool, earmuffed: Bool)
    
    /// Get member details
    case details(conversationId: String, memberId: String)
    
    /// Kick a user out of a conversation
    case kick(conversationId: String, memberId: String)
    
    // MARK:
    // MARK: Request
    
    private var method: HTTPMethod {
        switch self {
        case .invite: return .post
        case .inviteWithAudio: return .post
        case .details: return .get
        case .kick: return .delete
        }
    }
    
    private var path: String {
        switch self {
        case .invite(_, let conversationId): return "/conversations/\(conversationId)/members"
        case .inviteWithAudio(_, _, let conversationId, _, _): return "/conversations/\(conversationId)/members"
        case .details(let conversationId, let memberId): return "/conversations/\(conversationId)/members/\(memberId)"
        case .kick(let conversationId, let memberId): return "/conversations/\(conversationId)/members/\(memberId)"
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
        case .invite(let username, _):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: MembershipBuilder.invite(username: username).parameters)
        case .inviteWithAudio(let userId, let username, _, let muted, let earmuffed):
            urlRequest = try JSONEncoding.default.encode(
                urlRequest, 
                with: MembershipBuilder.inviteWithAudio(userId: userId, userName: username, muted: muted, earmuffed: earmuffed).parameters)
        case .details:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .kick:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        }
        
        return urlRequest
    }
}
