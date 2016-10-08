//
//  MuttleyError.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

public enum MuttleyError {
    
    case invalidURL
    case timeOut
    case network(statusCode: Int, localizedDescription: String)
    case invalidFormat
    
//    static func create(error: NSError?, response: HTTPURLResponse?) -> MuttleyError? {
//        
//        if response == nil {
//            return .timeOut
//        }
//        
//        if let response = response, response.statusCode > 299 {
//            return .network(response.statusCode, NSHTTPURLResponse.localizedStringForStatusCode(response.statusCode))
//        }
//        
//        if let error = error {
//            return .network(response?.statusCode, error.localizedDescription)
//        }
//        
//        return nil
//    }
}
