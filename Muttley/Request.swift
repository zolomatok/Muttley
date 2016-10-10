//
//  Resource.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

/// Defines the url for a resource, along with an optional parsing method, configuration, progress and completion handlers
open class Request<T> {
    
    public typealias Completion = (T?, MuttleyError?)->Void
    public typealias ProgressHandler = (Double)->Void
    
    open let url: String
    open var parser: Parser?
    open var configuration: URLSessionConfiguration?
    open let progressHandler: ProgressHandler?
    open let completion: Completion
    
    public init(url: String, parser: Parser? = nil, configuration: URLSessionConfiguration? = nil, progressHandler: ProgressHandler? = nil, completion: @escaping Completion) {
        
        self.url = url
        self.parser = parser
        self.configuration = configuration
        self.progressHandler = progressHandler
        self.completion = completion
        
        // !! Despite the warning, Request<T> is not unrelated to Request<Data> and the cast does not always fail. This warning is a false positive, but there is no way to suppress a specific warning in Swift 3.
        assert(self is Request<Data> || parser != nil, "[Muttley] A 'Parser' is needed as input parameter for the initializer of 'Request' if the generic type is not Data")
    }
}
