//
//  Loader.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

class Loader {
    static func load(url: URL, completion: @escaping (Data?, MuttleyError?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let response = response as? HTTPURLResponse
            var muttleyError: MuttleyError?
            
            
            // Handle error
            if response == nil { muttleyError = .timeOut }
            if let response = response, response.statusCode > 299 {
                muttleyError = .networkError(statusCode: response.statusCode, localizedDescription: HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
            }
            if let error = error {
                muttleyError = .networkError(statusCode: response?.statusCode ?? 0, localizedDescription: error.localizedDescription)
            }
            
            
            // Completion
            DispatchQueue.main.async {
                completion(data, muttleyError)
            }

        }.resume()
    }
}
