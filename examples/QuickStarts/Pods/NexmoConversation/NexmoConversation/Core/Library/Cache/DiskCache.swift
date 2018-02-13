//
//  DiskCache.swift
//  NexmoConversation
//
//  Created by shams ahmed on 16/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

/// Disk Cache
internal struct DiskCache {

    private let fileManager = FileManager.default
    private let queue = DispatchQueue.io

    /// List of cached paths
    internal let directory: String

    /// list of files
    internal var contents: [String] {
        guard let contents = try? self.fileManager.contentsOfDirectory(atPath: self.directory), !contents.isEmpty else {
            return []
        }

        return contents
    }
    
    // MARK:
    // MARK: Initializers

    /// Create cache at a specfic location
    ///
    /// - Parameter path: location
    internal init(with path: String) {
        self.directory = path
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        queue.async { try? self.fileManager.createDirectory(
            atPath: self.directory, 
            withIntermediateDirectories: true)
        }
    }
    
    // MARK:
    // MARK: Setter/Getter

    /// Get file with Type
    ///
    /// - Parameters:
    ///   - key: key
    ///   - completion: result
    internal func get<T>(_ key: String, _ completion: @escaping ((T?) -> Void)) {
        queue.async {
            let file = (self.directory as NSString).appendingPathComponent(key)
            let object = NSKeyedUnarchiver.unarchiveObject(withFile: file) as? T

            completion(object)
        }
    }

    /// Set asset with key
    ///
    /// - Parameters:
    ///   - key: key
    ///   - value: value
    /// - Returns: path of file, only if successful
    @discardableResult
    internal func set(key: String, value: Any) -> String {
        let path = (directory as NSString).appendingPathComponent(key)
        
        queue.async {
            self.fileManager.createFile(
            atPath: path,
            contents: NSKeyedArchiver.archivedData(withRootObject: value)
            )
        }

        return path
    }
    
    // MARK:
    // MARK: Exist

    /// Search for file at a given path
    ///
    /// - Parameter path: path to search
    /// - Returns: result
    internal func fileExist(at path: String) -> Bool {
        return contents.contains(path)
    }
    
    // MARK:
    // MARK: Remove

    /// Remove file a path
    ///
    /// - Parameters:
    ///   - path: path of file
    ///   - completion: result
    internal func remove(key path: String, _ completion: (() -> Void)? = nil) {
        queue.async {
            try? self.fileManager.removeItem(atPath: (self.directory as NSString).appendingPathComponent(path))

            completion?()
        }
    }

    /// Remove all data
    ///
    /// - Parameter completion: result
    internal func removeAll(_ completion: (() -> Void)? = nil) {
        queue.async {
            try? self.fileManager.contentsOfDirectory(atPath: self.directory).forEach {
                try? self.fileManager.removeItem(atPath: (self.directory as NSString).appendingPathComponent($0))
            }

            completion?()
        }
    }
}
