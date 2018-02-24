//
//  AssetController.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 21/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Converts raw data to specfic type
internal protocol RawDecodable {

    // MARK:
    // MARK: Initializers

    /// Create object of type T
    init?(_ data: Data)
}

/// Asset controller handles fetching assets
internal class AssetController: NSObject {

    // MARK:
    // MARK: Properties

    /// Network controller
    private let networkController: NetworkController

    /// Rx
    private let disposeBag = DisposeBag()
    
    /// Queue to handle downloads
    internal let queue = DownloadQueue()
    
    // MARK:
    // MARK: Initializers

    internal init(network: NetworkController) {
        networkController = network
    }

    // MARK:
    // MARK: Download

    /// Download object
    ///
    /// - Parameters:
    ///   - url: path of object
    /// - Returns: observable with result of T
    internal func download<T: RawDecodable>(at url: String) -> Single<T> {
        return Single<T>.create { observer -> Disposable in
            self.networkController.mediaService.download(
                at: url,
                success: { observer(.success($0)) },
                failure: { observer(.error($0)) }
            )

            return Disposables.create()
        }
        .observeOn(queue.queue)
    }
}
