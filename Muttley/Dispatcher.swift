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

            
            // Clear the queue but copy the dispatch requests before removing them
            // The completions must be called last, because this request could be re-called in the a completion block before being removed
            // Since the request would already be in the queue (albeit finished) the new request would just be added to the queue and would wait eternally for the first one to finish
            let dispatchRequests = self.queue[request.url]
            self.queue.removeValue(forKey: request.url)
            
            
            // Remove the loader
            loaders = loaders.filter{ $0.url.absoluteString != request.url }

            
            // Completion
            dispatchRequests?.forEach({ (dpRequest) in
                dpRequest.completion(data, error)
            })
        }
    }
    
    
    static func cancel(request: Request) {
        if let items = queue[request.url],
            
            // Index
            let index = items.index(where: { $0.uid == request.uid }) {
        
            // Call the completion
            if let dispatchRequests = queue[request.url] {
                dispatchRequests[index].completion(nil, .cancelled)
            }
            
            // Remove the dispatch request
            queue[request.url]?.remove(at: index)
            
            // Remove the key if no requests are left for the url
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
