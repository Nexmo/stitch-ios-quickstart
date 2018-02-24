//
//  NetworkError.swift
//  NexmoConversation
//
//  Created by paul calver on 13/06/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Network error protocol
public protocol NetworkErrorProtocol: Error {

    /// Error type
    var type: String { get }

    /// Error message
    var message: String { get }

    /// Network Request URL
    var requestURL: String? { get }

    /// Status code of request or Error code
    var code: Int? { get }
    
    /// Stacktrace
    var stacktrace: [String] { get }
}

/// Network error
public struct NetworkError: NetworkErrorProtocol, Decodable {
    
    // MARK:
    // MARK: Properties
    
    /// Error type
    public var type: String
    
    /// Error message
    public var message: String
    
    /// Network Request URL
    public var requestURL: String?
    
    /// Status code of request or Error code
    public var code: Int?
    
    /// Stacktrace
    public var stacktrace = [String]()
    
    // MARK:
    // MARK: Initializers

    internal init(from response: DataResponse<Data>) throws {
        guard let data = response.data else { throw JSONError.malformedJSON }
        let decoder = try JSONDecoder().decode([String: String].self, from: data)
        
        guard let type = decoder["code"],
            let description = decoder["description"],
            let url = response.response?.url?.absoluteString,
            let statusCode = response.response?.statusCode else {
            throw JSONError.malformedJSON
        }
        
        self.type = type
        message = description
        requestURL = url
        code = statusCode
        stacktrace = Thread.callStackSymbols
    }
    
    internal init(from response: DataResponse<Any>) throws {
        guard let data = response.data else { throw JSONError.malformedJSON }
        let decoder = try JSONDecoder().decode([String: String].self, from: data)
        
        guard let type = decoder["code"],
            let description = decoder["description"],
            let url = response.response?.url?.absoluteString,
            let statusCode = response.response?.statusCode else {
            throw JSONError.malformedJSON
        }

        self.type = type
        message = description
        requestURL = url
        code = statusCode
        stacktrace = Thread.callStackSymbols
    }

    internal init(type: String="", localizedDescription: String="", from response: DefaultDataResponse) {
        self.type = type.isEmpty ? (response.error?.localizedDescription ?? type) : type
        message = localizedDescription
        requestURL = response.request?.url?.absoluteString
        code = response.response?.statusCode
        stacktrace = Thread.callStackSymbols
        
        // if data was passed, try and use it to compose the error title and description
        if let data = response.data,
            let decoder = try? JSONDecoder().decode([String: String].self, from: data),
            let code = decoder["code"],
            let description = decoder["description"] {
            self.type = code
            message = description
        }
    }
}

extension NetworkError: CustomStringConvertible {
    
    // MARK:
    // MARK: Description
    
    /// Description
    /// :nodoc:
    public var description: String {
        let url = requestURL ?? "n/a"
        let errorCode = code.map { String($0) } ?? "n/a"
        let stack = stacktrace.joined(separator: "\n")
        
        // build description
        var description = ""
        description += "type: \(type)\n"
        description += "description: \(message)\n"
        description += "requestURL: \(url)\n"
        description += "errorCode: \(errorCode)\n"
        description += "stacktrace: \(stack)"
        
        return description
    }
}

extension NetworkError: LocalizedError {
    
    // MARK:
    // MARK: NSError (Objective-C compatibility support)
    
    /// Error Description
    /// :nodoc:
    public var errorDescription: String? {
        return self.message
    }
}
