//
//  Memory.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

class Memory: NSCache<NSString, NSData> {
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllObjects), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
     }
    
    subscript(key: String) -> NSData? {
        
        get {
            return object(forKey: key as NSString)
        }
        
        set(newValue) {
            if let newValue = newValue {
                setObject(newValue, forKey: key as NSString)
            } else {
                removeObject(forKey: key as NSString)
            }
        }
    }
}
