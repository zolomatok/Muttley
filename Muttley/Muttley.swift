//
//  Muttley.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

open class Muttley<T> {
    
    
    func test() {

        let request = Request<UIImage>(url: "https://google.com") { (img, error) in
            
        }
        Muttley<UIImage>(parser: ImageParser()).fetch(request: request)
    }
    
    
    var ongoing = [String: [Request<T>]]()
    open let parser: Parser

    
    init(parser: Parser, configuration: URLSessionConfiguration? = nil) { self.parser = parser }
    
    
    open func fetch(request: Request<T>) {
        
        // 1| Check the cache for the data
        if let data = Memory.shared[request.url] as? T {
            request.completion(data, nil)
            return
        }
        
        
        // 2| Add the request to ongoing queue if exists for the URL
        if ongoing.keys.contains(request.url) {
            ongoing[request.url]!.append(request)
            return
        }
        
        
        // 3| Create the URL
        guard let url = URL(string:request.url) else {
            request.completion(nil, .invalidURL)
            return
        }
        
        
        // 4| Load
        Loader.load(url: url, parser: parser) { (data, error) in
            
            // Completion
            let data = data as? T
            let requests = self.ongoing[request.url]
            requests?.forEach({ (stored) in
                stored.completion(data, error)
            })
            
            
            // Cache
            Memory.shared[request.url] = data as AnyObject?
            
            
            // Clear the queue
            self.ongoing.removeValue(forKey: request.url)
        }
    }
    
    
    open func configure(maxCapacity: UInt64) {
        // capaccity
        // NSURLSessionConfiguration
    }
    
    
    open func clean() {
        // Clear the NSCache
        Memory.shared.cache.removeAllObjects()
    }
}
