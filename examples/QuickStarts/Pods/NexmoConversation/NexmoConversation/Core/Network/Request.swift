//
//  Request.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 30/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Status of network calls
public struct Request {

    /// Request
    private let request: DataRequest

    // MARK:
    // MARK: Properties

    /// Current progress of request
    public var state: Progress { return request.progress }

    /// HTTP URL response
    internal var response: HTTPURLResponse? { return request.response }
    
    // MARK:
    // MARK: Initializers

    internal init(with request: DataRequest) {
        self.request = request
    }

    // MARK:
    // MARK: Progress

    /// See the progress of request
    ///
    /// - Parameter progress: periodically progress
    public func progress(_ progress: @escaping (Progress) -> Void) {
        if let request = request as? UploadRequest {
            request.uploadProgress(closure: progress)
        } else {
            request.downloadProgress(closure: progress)
        }
    }

    // MARK:
    // MARK: Operation

    /// Cancel request
    ///
    /// - Returns: Request could be cancelled
    @discardableResult
    public func cancel() -> Bool {
        guard request.progress.isCancellable else { return false }

        request.cancel()

        return true
    }
}
