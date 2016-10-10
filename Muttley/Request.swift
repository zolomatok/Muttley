//
//  Resource.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

open class Request<T> {
    
    open let url: String
    open var parser: Parser?
    open var configuration: URLSessionConfiguration?
    public typealias Completion = (T?, MuttleyError?)->Void
    open let completion: Completion
    
    public init(url: String, parser: Parser? = nil, configuration: URLSessionConfiguration? = nil, completion: @escaping Completion) {
        
        self.url = url
        self.parser = parser
        self.configuration = configuration
        self.completion = completion
        
        // !! Despite the warning, Request<T> is not unrelated to Request<Data> and the cast does not always fail. This warning is a false positive, but there is no way to suppress a specific warning in Swift 3.
        assert(self is Request<Data> || parser != nil, "[Muttley] A 'Parser' is needed as input parameter for the initializer of 'Request' if the generic type is not Data")
    }
}
