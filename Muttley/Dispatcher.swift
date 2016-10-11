//
//  Dispatcher.swift
//  Muttley
//
//  Created by Zolo on 10/10/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation


class Dispatcher {
    
    fileprivate static var queue = [String: [DispatchRequest]]()
    fileprivate static var loaders = [Loader]()
    static var memory: Memory = {
        let m = Memory()
        m.totalCostLimit = Int.max
        return m
    }()
    
    
    static func fetch(request: DispatchRequest) {
        
        // 1| Check the cache for the data
        if let data = memory[request.url] as? Data {
            request.completion(data, nil)
            return
        }
        
        
        // 2| Add the completion to the queue
        if queue.keys.contains(request.url) {
            queue[request.url]!.append(request)
            return
        } else {
            queue[request.url] = [request]
        }
        
        
        // 3| Create the URL
        guard let weburl = URL(string: request.url) else {
            request.completion(nil, .invalidURL)
            return
        }
        
        
        // 4| Load
        let loader = Loader(url: weburl)
        loaders.append(loader)
        loader.load(configuration: request.configuration, progressHandler: request.progressHandler ?? {_ in}) { (data, error) in
            
            // Cache
            memory[request.url] = data as NSData?

            
            // Completion
            let completions = self.queue[request.url]
            completions?.forEach({ (completion) in
                request.completion(data, error)
            })
            
            
            // Clear the queue
            self.queue.removeValue(forKey: request.url)
            
            
            // Remove the loader
            loaders = loaders.filter{ $0.url.absoluteString != request.url }
        }
    }
    
    
    static func cancel(request: Request) {
        if let items = queue[request.url],
            
            // Index
            let index = items.index(where: { $0.uid == request.uid }) {
        
            // Remove the completion
            queue[request.url]?.remove(at: index)
            
            // Remove the key if no completions are left
            if queue[request.url]!.count == 0 {
                queue.removeValue(forKey: request.url)
                
                // Cancel and remove the loaders associated with this url
                loaders = loaders.filter({ loader in
                
                    if loader.url.absoluteString != request.url {
                        return true
                    } else {
                        loader.cancel()
                        return false
                    }
                })
            }
        }
    }
    
    
    static func clean() {
        memory.removeAllObjects()
    }
}
