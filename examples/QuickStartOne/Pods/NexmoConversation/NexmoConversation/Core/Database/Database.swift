//
//  Database.swift
//  NexmoConversation
//
//  Created by James Green on 26/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import GRDB

/// Database
internal struct Database {
    
    /// Nice helper to avoid importing GRDB all around the codebase
    internal typealias Provider = GRDB.Database
    
    // MARK:
    // MARK: Singleton
    
    /// Static accessor for database singleton.
    internal static let `default`: Database = { return Database() }()

    // MARK:
    // MARK: Static
    
    /// DB path
    private static var path: String {
        // Unit testing is run in sandbox mode, document directory are off limits
        guard !Environment.inTesting else {
            return "\(NSTemporaryDirectory())\(ProcessInfo.processInfo.globallyUniqueString)"
        }
        
        return Constants.SDK.documentPath + "/\(Constants.SDK.name).sqlite"
    }
    
    // MARK:
    // MARK: Queue
    
    /// Read/Write queue
    internal let queue: DatabaseQueue = {
        do {
            // GRDB requires directory to exist before SQLite open connection
            try FileManager.default.createDirectory(atPath: Constants.SDK.documentPath, withIntermediateDirectories: true)
            
            return try DatabaseQueue(path: Database.path)
        } catch {
            Log.info(.database, "Failed to open database")
        }
        
        Log.info(.database, "Using in-memory for database failback")
        
        return DatabaseQueue()
    }()

    // MARK:
    // MARK: Initializers
    
    internal init() {
   
    }
    
    // MARK:
    // MARK: Migrator
    
    internal func migrate(_ version: String, _ closure: @escaping (Database.Provider) -> Void) throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigration(version) { closure($0) }
        
        try migrator.migrate(queue)
    }
}
