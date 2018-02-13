//
//  Image.swift
//  NexmoConversation
//
//  Created by shams ahmed on 25/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Image Processing service
public struct IPS {
    
    // MARK:
    // MARK: Enum
    
    /// Types of images sent from server
    ///
    /// - original: original
    /// - medium: medium
    /// - thumbnail: thumbnail
    public enum ImageType: String, Equatable, CodingKey {
        case original
        case medium
        case thumbnail
    }
}

internal extension Event.Body {

    /// Image model from media server
    internal struct Image: Decodable {

        // MARK:
        // MARK: Enum
        
        private enum CodingKeys: String, CodingKey {
            case id
            case representations
        }
        
        /// Type of images available
        ///
        /// - link: link with image data and size
        internal enum Metadata: Equatable, Decodable {
            
            // MARK:
            // MARK: Key
            
            internal enum CodingKeys: String, CodingKey {
                case id
                case type
                case size
                case url
            }
            
            case link(id: String, url: URL, type: IPS.ImageType, size: Int)

            // MARK:
            // MARK: Initializers

            /// create image location model
            ///
            /// - parameter json: json
            ///
            /// - returns: image model
            internal static func create(json: [String: Any]) -> Metadata? {
                guard let type = json["type"] as? String, let imageType = IPS.ImageType(rawValue: type.lowercased()) else { return nil }
                guard let id = json["id"] as? String, let url = json["url"] as? String, let size = json["size"] as? Int else { return nil }
                guard let urlObject = URL(string: url) else { return nil }
                
                return Metadata.link(id: id, url: urlObject, type: imageType, size: size)
            }
            
            internal init(from decoder: Decoder) throws {
                let allValues = try decoder.container(keyedBy: CodingKeys.self)
                
                guard let type = IPS.ImageType(rawValue: try allValues.decode(String.self, forKey: .type).lowercased()) else {
                    throw JSONError.malformedJSON
                }
                
                let id = try allValues.decode(String.self, forKey: .id)
                let size = try allValues.decode(Int.self, forKey: .size)
                let url = try allValues.decode(URL.self, forKey: .url)
                
                self = .link(id: id, url: url, type: type, size: size)
            }

            // MARK:
            // MARK: JSON

            /// Convert model to JSON
            internal var json: [String: Any] {
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
            self.images = [
                Metadata.link(id: id, url: url, type: .thumbnail, size: size),
                Metadata.link(id: id, url: url, type: .medium, size: size),
                Metadata.link(id: id, url: url, type: .original, size: size)
            ]
        }

        internal init?(json: [String: Any]) {
            let json: [String: Any] = json[CodingKeys.representations.rawValue] as? [String: Any] ?? json
            
            guard let id = json[CodingKeys.id.rawValue] as? String else { return nil }

            self.id = id
            self.images = [
                json[IPS.ImageType.medium.rawValue],
                json[IPS.ImageType.thumbnail.rawValue],
                json[IPS.ImageType.original.rawValue]]
                    .flatMap { $0 as? [String: Any] }
                    .flatMap { Metadata.create(json: $0) }
        }
        
        internal init(from decoder: Decoder) throws {
            let allValues = try decoder.container(keyedBy: CodingKeys.self)
            
            struct Representation: Decodable {
                
                // MARK:
                // MARK: Key
                
                enum CodingKeys: String, CodingKey {
                    case id
                    case thumbnail
                    case medium
                    case original
                }
                
                // MARK:
                // MARK: Initializers
                
                let id: String
                let thumbnail: Metadata
                let medium: Metadata
                let original: Metadata
                
                init(from decoder: Decoder) throws {
                    let allValues = try decoder.container(keyedBy: CodingKeys.self)
                    
                    id = try allValues.decode(String.self, forKey: .id)
                    thumbnail = try allValues.decode(Metadata.self, forKey: .thumbnail)
                    medium = try allValues.decode(Metadata.self, forKey: .medium)
                    original = try allValues.decode(Metadata.self, forKey: .original)
                }
            }
            
            var representation: Representation? {
                return !allValues.contains(.representations)
                    ? try? decoder.singleValueContainer().decode(Representation.self)
                    : try? allValues.decode(Representation.self, forKey: .representations)
            }
            
            guard let representations = representation else { throw JSONError.malformedJSON }
            
            id = representations.id
            images = [
                representations.original,
                representations.thumbnail,
                representations.medium
            ]
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
        internal var json: [String: Any] {
            let thumbnail = image(for: .thumbnail)
            let medium = image(for: .medium)
            let original = image(for: .original)
            
            return [
                "id": id,
                "original": original?.json ?? [:],
                "medium": medium?.json ?? [:],
                "thumbnail": thumbnail?.json ?? [:]
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
