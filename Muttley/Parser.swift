//
//  Parser.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

public protocol Parser {
    func parse(data: Data?) -> Any?
}

open class ImageParser: Parser {
    public init() {} // Without this, the parser cannot be initialized outside the lib
    open func parse(data: Data?) -> Any? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}

open class JSONParser: Parser {
    public init() {} // Without this, the parser cannot be initialized outside the lib
    open func parse(data: Data?) -> Any? {
        guard let data = data else { return nil }
        let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
        return json as? [String: AnyObject] ?? json as? [[String: AnyObject]]
    }
}
