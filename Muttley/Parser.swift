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

public class ImageParser: Parser {
    public func parse(data: Data?) -> Any? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}

public class HTMLParser: Parser {
    public func parse(data: Data?) -> Any? {
        guard let data = data else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}

public class JSONParser: Parser {
    public func parse(data: Data?) -> Any? {
        guard let data = data else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
    }
}
