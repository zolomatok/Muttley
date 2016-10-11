//
//  Resource.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

/// Defines the url for a resource, along with an optional parsing method, configuration, progress and completion handlers
public class Request {
    
    public typealias ProgressHandler = (Double)->Void
    
    public let uid: UInt32
    public let url: String
    public var parser: Parser?
    public var configuration: URLSessionConfiguration?
    public let progressHandler: ProgressHandler?
    
    public init(uid: UInt32 = arc4random_uniform(UInt32.max), url: String, parser: Parser? = nil, configuration: URLSessionConfiguration? = nil, progressHandler: ProgressHandler? = nil) {
        
        self.uid = uid
        self.url = url
        self.parser = parser
        self.configuration = configuration
        self.progressHandler = progressHandler        
    }
}


/// Request with completion handler
class DispatchRequest: Request {
    let completion: (Data?, MuttleyError?)->Void
    
    init(request: Request, completion: @escaping (Data?, MuttleyError?)->Void) {
        self.completion = completion
        super.init(uid: request.uid, url: request.url, parser: request.parser, configuration: request.configuration, progressHandler: request.progressHandler)
    }
}
