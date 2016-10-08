//
//  Memory.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

class Memory {
    
    static let shared = Memory()
    let cache = NSCache<NSString, AnyObject>()
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(cache.removeAllObjects), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
     }
    
    subscript(key: String) -> AnyObject? {
        
        get {
            return cache.object(forKey: key as NSString)
        }
        
        set(newValue) {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: key as NSString)
            } else {
                cache.removeObject(forKey: key as NSString)
            }
        }
    }
}
