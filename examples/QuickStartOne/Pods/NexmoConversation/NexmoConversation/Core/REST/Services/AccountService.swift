//
//  AccountService.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 31/10/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Account service calls, auth, login, user
internal struct AccountService {
    
    /// Network manager
    private let manager: HTTPSessionManager
    
    // MARK:
    // MARK: Initializers

    internal init(manager: HTTPSessionManager) {
        self.manager = manager
    }
    
    // MARK:
    // MARK: User
    
    /// Fetch a user
    ///
    /// - parameter uuid: uuid
    /// - parameter success: success with user model
    /// - parameter failure: failure
    ///
    /// - returns: request
    @discardableResult
    internal func user(with id: String, success: @escaping (UserModel) -> Void, failure: @escaping (Error) -> Void) -> DataRequest {
        return manager
            .request(AccountRouter.user(id: id))
            .validateAndReportError(to: manager)
            .responseData(queue: manager.queue, completionHandler: {
                switch $0.result {
                case .failure(let error):
                    failure((try? NetworkError(from: $0)) ?? error)
                case .success(let response):
                    guard let model = try? JSONDecoder().decode(UserModel.self, from: response) else {
                        return failure(JSONError.malformedJSON)
                    }

                    success(model)
                }
            }
        )
    }
}
