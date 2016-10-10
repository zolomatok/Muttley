//
//  Loader.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

class Loader: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var dataToDownload = Data()
    var size: Int64 = 0
    var progressHandler: ((Double)->Void)?
    var completion: ((Data?, MuttleyError?) -> Void)!
    
    func load(url: URL, configuration: URLSessionConfiguration? = nil, progressHandler: @escaping (Double) -> Void = {_ in}, completion: @escaping (Data?, MuttleyError?) -> Void) {
    
        self.progressHandler = progressHandler
        self.completion = completion
    
        let session = URLSession(configuration: configuration ?? URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url)
        task.resume()
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        size = response.expectedContentLength
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        dataToDownload.append(data)
        self.progressHandler?(Double(dataToDownload.count)/Double(size))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let response = task.response as? HTTPURLResponse
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
        DispatchQueue.main.async { self.completion(self.dataToDownload, muttleyError) }
    }
}
