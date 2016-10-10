//
//  Muttley.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation


open class Muttley {
    
    
    open static var maxCapacity: Int {
        get { return Dispatcher.memory.totalCostLimit }
        set { Dispatcher.memory.totalCostLimit = newValue }
    }
    
    
    open static func fetch<T>(request: Request<T>) {
        
        Dispatcher.fetch(url: request.url, configuration: request.configuration, progressHandler: request.progressHandler ?? {_ in}) { (data, error) in
            
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
    

    open static func clean() {
        Dispatcher.clean()
    }
}
