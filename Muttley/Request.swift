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
    public typealias Completion = (T?, MuttleyError?)->Void
    open let completion: Completion
    
    public init(url: String, completion: @escaping Completion) {
        self.url = url
        self.completion = completion
    }
}
