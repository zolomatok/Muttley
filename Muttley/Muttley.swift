//
//  Muttley.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation


open class Muttley<T> {
    
    open static func fetch(request: Request<T>) {
        
        Dispatcher.fetch(url: request.url) { (data, error) in
            
            guard error == nil else {
                request.completion(nil, error)
                return
            }
            

            // Parse
            if let parser = request.parser, let data = data {
                if let result = parser.parse(data: data) as? T {
                    request.completion(result, nil)
                } else {
                    request.completion(nil, .parseError("Expected \(T.self)"))
                }
                return
            }
            
            
            // Data without parsing
            request.completion(data as? T, error)
        }
    }
    
    
    open static func configure(maxCapacity: UInt64) {
        // capaccity
        // NSURLSessionConfiguration
    }
    
    
    open static func clean() {
        Dispatcher.clean()
    }
}
