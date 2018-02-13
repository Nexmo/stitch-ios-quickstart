//
//  MediaService.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 18/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Media service to handle downloading of assets
internal struct MediaService {

    /// Network manager
    private let manager: HTTPSessionManager

    // MARK:
    // MARK: Initializers

    internal init(manager: HTTPSessionManager) {
        self.manager = manager
    }

    // MARK:
    // MARK: State

    /// Download an asset
    ///
    /// - parameter url: url link
    /// - parameter success: success with asset model
    /// - parameter failure: failure
    ///
    /// - returns: request
    @discardableResult
    internal func download<T: RawDecodable>(at url: String, success: @escaping (T) -> Void, failure: @escaping (Error) -> Void) -> DataRequest {
        return manager
            .request(MediaRouter.download(url: url))
            .validateAndReportError(to: manager)
            .responseData(queue: manager.queue, completionHandler: {
                switch $0.result {
                case .failure(let error):
                    failure(error)
                case .success(let response):
                    guard let model = T(response) else { return failure(JSONError.malformedJSON) }

                    success(model)
                }
            })
    }
}
