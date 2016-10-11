//
//  Muttley.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation


open class Muttley {
    
    
    /// Maximum size of the memory in bytes. Note, this is imprecise as it uses NSCache.
    open static var maxCapacity: Int {
        get { return Dispatcher.memory.totalCostLimit }
        set { Dispatcher.memory.totalCostLimit = newValue }
    }
    

    /// Download the data from the request's url
    open static func fetch<T>(request: Request, completion: @escaping (T?, MuttleyError?)->Void) {
        
        
        // Handle the completion
        let dispatchRequest = DispatchRequest(request: request) { (data, error) in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            
            // Parse
            if let parser = request.parser, let data = data {
                if let result = parser.parse(data: data) as? T {
                    completion(result, nil)
                } else {
                    completion(nil, .parseError("Expected \(T.self)"))
                }
                return
            }
            
            
            // Data without parsing
            completion(data as? T, error)
        }
        
        
        // Run the request
        Dispatcher.fetch(request: dispatchRequest)
    }
    
    
    /// Cancels a specific request
    open static func cancel(request: Request) {
        Dispatcher.cancel(request: request)
    }
    

    /// Cleans the cache in its entirity
    open static func cleanCache() {
        Dispatcher.clean()
    }
}
