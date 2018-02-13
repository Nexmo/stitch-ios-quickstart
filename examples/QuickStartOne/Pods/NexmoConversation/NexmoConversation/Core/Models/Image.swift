//
//  Image.swift
//  NexmoConversation
//
//  Created by shams ahmed on 25/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Gloss

public struct IPS {
    
    // MARK:
    // MARK: Enum
    
    /// Types of images sent from server
    ///
    /// - original: original
    /// - medium: medium
    /// - thumbnail: thumbnail
    public enum ImageType: String, Equatable {
        case original
        case medium
        case thumbnail
    }
}

internal extension Event.Body {

    /// Image model from media server
    internal struct Image: Gloss.JSONDecodable {

        /// Type of images available
        ///
        /// - link: link with image data and size
        internal enum Metadata: Equatable {
            case link(id: String, url: URL, type: IPS.ImageType, size: Int)

            // MARK:
            // MARK: Initializers

            /// create image location model
            ///
            /// - parameter json: json
            ///
            /// - returns: image model
            internal static func create(json: JSON) -> Metadata? {
                guard let type: String = "type" <~~ json, let imageType = IPS.ImageType(rawValue: type.lowercased()) else { return nil }
                guard let id: String = "id" <~~ json, let url: URL = "url" <~~ json, let size: Int = "size" <~~ json else { return nil }

                return Metadata.link(id: id, url: url, type: imageType, size: size)
            }

            // MARK:
            // MARK: JSON

            /// Convert model to JSON
            internal var toJSON: JSON {
                switch self {
                case .link(let id, let url, let type, let size):
                    return [
                        "url": url.absoluteString,
                        "id": id,
                        "type": type.rawValue,
                        "size": size
                    ]
                }
            }
        }

        // MARK:
        // MARK: Properties

        /// Id of image location
        internal let id: String

        /// All available images, use method instead
        private let images: [Image.Metadata]

        // MARK:
        // MARK: Initializers
        
        /// Draft image
        internal init(id: String, path: String, size: Int) {
            let url = URL(fileURLWithPath: path)

            self.id = id
            self.images = [Metadata.link(id: id, url: url, type: .thumbnail, size: size)]
        }

        internal init?(json: JSON) {
            let json: JSON = json["representations"] as? JSON ?? json
            
            guard let id: String = "id" <~~ json else { return nil }

            self.id = id

            self.images = [
                json[IPS.ImageType.medium.rawValue],
                json[IPS.ImageType.thumbnail.rawValue],
                json[IPS.ImageType.original.rawValue]]
                    .flatMap { $0 as? JSON }
                    .flatMap { Metadata.create(json: $0) }
        }

        // MARK:
        // MARK: Helper

        /// Get image from a type
        ///
        /// - parameter type: image type
        ///
        /// - returns: image model
        internal func image(for type: IPS.ImageType) -> Image.Metadata? {
            return images.first(where: {
                guard case .link(_, _, let imageType, _) = $0, imageType == type else { return false }

                return true
            })
        }
        
        // MARK:
        // MARK: JSON
        
        /// Convert model to JSON
        internal func toJSON() -> JSON {
            let thumbnail = image(for: .thumbnail)
            let medium = image(for: .medium)
            let original = image(for: .original)
            
            return [
                "id": id,
                "original": original?.toJSON ?? [:],
                "medium": medium?.toJSON ?? [:],
                "thumbnail": thumbnail?.toJSON ?? [:]
                ]
        }
    }
}

// MARK:
// MARK: Compare

/// Compare Image Link
/// :nodoc:
internal func ==(lhs: Event.Body.Image.Metadata, rhs: Event.Body.Image.Metadata) -> Bool {
    switch (lhs, rhs) {
    case (.link(let id0, let url0, let type0, let size0), .link(let id1, let url1, let type1, let size1)):
        return id0 == id1 && url0 == url1 && type0 == type1 && size0 == size1
    }
}

/// Compare ImageType
/// :nodoc:
public func ==(lhs: IPS.ImageType, rhs: IPS.ImageType) -> Bool {
    switch (lhs, rhs) {
    case (.original, .original): return true
    case (.medium, .medium): return true
    case (.thumbnail, .thumbnail): return true
    case (.original, _),
         (.medium, _),
         (.thumbnail, _): return false
    }
}
