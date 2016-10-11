//
//  Loader.swift
//  Muttley
//
//  Created by Zolo on 10/8/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import Foundation

class Loader: NSObject {
    
    let url: URL
    var session: URLSession!
    var dataToDownload = Data()
    var size: Int64 = 0
    var progressHandler: ((Double)->Void)?
    var completion: ((Data?, MuttleyError?) -> Void)!
    
    init(url: URL) { self.url = url }
    
    
    func load(configuration: URLSessionConfiguration? = nil, progressHandler: @escaping (Double) -> Void = {_ in}, completion: @escaping (Data?, MuttleyError?) -> Void) {
    
        // Handlers
        self.progressHandler = progressHandler
        self.completion = completion
    
        
        // Session
        session = URLSession(configuration: configuration ?? URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        
        // Task
        session.dataTask(with: url).resume()
    }
    
    
    func cancel() {
        session.getTasksWithCompletionHandler { (dataTasks, _, _) in
            dataTasks.forEach{ $0.cancel() }
        }
    }
}



extension Loader: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        size = response.expectedContentLength
        completionHandler(.allow)
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        dataToDownload.append(data)
        self.progressHandler?(Double(dataToDownload.count)/Double(size))
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let error = error as NSError?
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
        // There can be partial data if it was a long task that was cancelled, so that should not be returned
        DispatchQueue.main.async { self.completion(muttleyError == nil ? self.dataToDownload : nil, muttleyError) }
    }
}
