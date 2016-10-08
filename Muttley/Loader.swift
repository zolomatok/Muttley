//
//  Loader.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

class Loader {
    static func load(url: URL, parser: Parser, completion: @escaping (Any?, MuttleyError?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let response = response as? HTTPURLResponse
            var muttleyError: MuttleyError?
            
            
            // Parse
            let parsed = parser.parse(data: data)

            
            // Handle error in a cascading way
            if parsed == nil { muttleyError = .invalidFormat }
            if response == nil { muttleyError = .timeOut }
            if let response = response, response.statusCode > 299 {
                muttleyError = .network(statusCode: response.statusCode, localizedDescription: HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
            }
            if let error = error {
                muttleyError = .network(statusCode: response?.statusCode ?? 0, localizedDescription: error.localizedDescription)
            }
            
            
            // Completion
            completion(parsed, muttleyError)

        }.resume()
    }
}
