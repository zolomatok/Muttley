//
//  Memory.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

class Memory: NSCache<NSString, NSData> {
    
    // The first item is the least recently used
    var accessFrequency = [(url: String, size: Int)]()
    override var totalCostLimit: Int { didSet { controlSize() } }
    
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(Memory.clean), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
     }
    
    
    subscript(key: String) -> NSData? {
        
        get {
            let data = object(forKey: key as NSString)
            if let data = data {
                if let index = accessFrequency.index(where: { $0.url == key }) {
                    accessFrequency.remove(at: index)
                }
                accessFrequency.append((key, data.length))
            }
            return data
        }
        
        set(newValue) {
            if let newValue = newValue {
                
                // Delete LRU if needed
                controlSize(sizeToAdd: newValue.length)
                
                // Record the item
                if !accessFrequency.contains { $0.url == key } {
                    accessFrequency.append((key, newValue.length))
                }
                
                setObject(newValue, forKey: key as NSString)
            }
        }
    }
    
    
    func controlSize(sizeToAdd: Int = 0) {
        
        // Current occupied size
        let currentSize: Int = accessFrequency.reduce(0, { (current, map) -> Int in current + map.1 })
        
        // Removing elements until there is enough room for the new one
        if currentSize + sizeToAdd > totalCostLimit {
            
            var subtract = 0
            var indices = [Int]()
            for (i, map) in accessFrequency.enumerated() {
                if subtract > totalCostLimit - sizeToAdd {
                    break
                }
                subtract += map.size
                indices.append(i)
            }
            indices.reversed().forEach{ accessFrequency.remove(at: $0) }
        }
    }
    
    
    
    func clean() {
        accessFrequency.removeAll()
        removeAllObjects()
    }
}
