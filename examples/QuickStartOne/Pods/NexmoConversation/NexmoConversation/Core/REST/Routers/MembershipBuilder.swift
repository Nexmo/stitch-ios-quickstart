//
//  MembershipBuilder.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Build parameters for membership request
internal enum MembershipBuilder {
    
    /// Build invite request
    case invite(username: String)
    case inviteWithAudio(userId: String, userName: String, muted: Bool, earmuffed: Bool)
    
    // MARK:
    // MARK: Model
    
    /// Build parameters
    internal var parameters: Parameters {
        switch self {
        case .invite(let username):
            return [
                "user_name": username,
                "action": MemberModel.Action.invite.rawValue,
                "channel": ["type": MemberModel.Channel.app.rawValue]
            ]
        case .inviteWithAudio(let userId, let userName, let muted, let earmuffed):
            return [
                "user_name": userName,
                "user_id": userId,
                "action": MemberModel.Action.invite.rawValue,
                "channel": ["type": MemberModel.Channel.app.rawValue],
                "media": ["audio": [
                    "muted": muted,
                    "earmuffed": earmuffed
                    ]
                ]
            ]
        }
    }
}
