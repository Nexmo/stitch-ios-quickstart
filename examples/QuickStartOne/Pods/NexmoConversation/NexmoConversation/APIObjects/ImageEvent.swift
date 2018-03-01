//
//  ImageEvent.swift
//  NexmoConversation
//
//  Created by James Green on 06/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

/// Image event
@objc(NXMImageEvent)
public class ImageEvent: TextEvent {

    // MARK:
    // MARK: Properties

    private let disposeBag = DisposeBag()
    
    // MARK:
    // MARK: Initializers
    
    internal init(conversationUuid: String, event: Event, seen: Bool, isDraft: Bool=false) {
        super.init(conversationUuid: conversationUuid, event: event, seen: seen)

        data.isDraft = isDraft
    }
    
    internal override init(data: DBEvent) {
        super.init(data: data)
    }
    
    internal init(conversationUuid: String, member: Member, isDraft: Bool, distribution: [String], seen: Bool) {
        super.init(conversationUuid: conversationUuid, type: .image, member: member, seen: seen)
       
        data.isDraft = isDraft
        data.distribution = distribution
    }

    // MARK:
    // MARK: Size
    
    /// File size of type
    ///
    /// - Parameter type: type of image
    /// - Returns: image size
    public func size(for type: IPS.ImageType) -> Int? {
        guard let model: Event.Body.Image = try? data.rest.model(),
            case .link(_, _, _, let size)? = model.image(for: type) else {
            return nil
        }
        
        return size
    }
    
    // MARK:
    // MARK: Image
    
    /// Fetch image of type
    ///
    /// - Parameters:
    ///   - type: type of image, @default: .thumbnail
    ///   - completion: success/failed
    public func image(for type: IPS.ImageType = .thumbnail, _ completion: @escaping ((Result<UIImage>) -> Void)) {
        // TODO: Remove use of 'ConversationClient.instance' for DI
        ConversationClient.instance.syncManager
            .syncImage(data.rest, for: type)
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onSuccess: { object in
                guard let image = UIImage(data: object.value) else {
                    return completion(.failed(ConversationClient.Errors.unknown("Failed to create UIImage")))
                }

                completion(.success(image))
            }, onError: { error in
                completion(.failed(error))
            }).disposed(by: disposeBag)
    }
}
