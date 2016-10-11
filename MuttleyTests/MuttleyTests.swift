//
//  MuttleyTests.swift
//  MuttleyTests
//
//  Created by Zolo on 10/10/16.
//  Copyright © 2016 Zolo. All rights reserved.
//

import XCTest
@testable import Muttley

class MuttleyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Muttley.cleanCache()
        Muttley.maxCapacity = Int.max
    }
    
    
    // MARK: - Request
    func testRequest() {
        
        let url = "https://cdn.shopify.com/s/files/1/0229/5765/products/fractalized.jpg?v=1467082024"
        let parser = ImageParser()
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["This" : "That"]
        let r = Request(url: url, parser: parser, configuration: config, progressHandler: {_ in })
        let d = DispatchRequest(request: r) { _ in }
        
        XCTAssertTrue(d.uid >= UInt32.min && r.uid <= UInt32.max && d.uid == r.uid)
        XCTAssertTrue(d.url == url)
        XCTAssertTrue(d.parser! is ImageParser)
        XCTAssertTrue(d.configuration! == config)
        XCTAssertTrue(d.progressHandler != nil)
    }
    
    
    // MARK: - Fetch
    func testFetch() {
        
        let ex = expectation(description: "Fetch")
        let r = Request(url: "https://cdn.shopify.com/s/files/1/0229/5765/products/fractalized.jpg?v=1467082024")
        
        Muttley.fetch(request: r) { (data: Data?, error) in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func testImageParsing() {
        
        let ex = expectation(description: "Image parsing")
        let r = Request(url: "https://cdn.shopify.com/s/files/1/0229/5765/products/fractalized.jpg?v=1467082024", parser: ImageParser())
        
        Muttley.fetch(request: r) { (image: UIImage?, error) in
            XCTAssertNotNil(image, "image should not be nil")
            XCTAssertNil(error, "error should be nil")
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    
    func testJSONParsing() {
        
        let ex = expectation(description: "JSON parsing")
        let r = Request(url: "https://api.github.com/users/mralexgray/repos", parser: JSONParser())
        
        Muttley.fetch(request: r) { (json: [[String: AnyObject]]?, error) in
            XCTAssertNotNil(json, "json should not be nil")
            XCTAssertNil(error, "error should be nil")
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func testSeparateParsingForIdenticalURLs() {
        
        let ex = expectation(description: "Cancel")
        var latch = 2 {
            didSet {
                if latch == 0 {
                    ex.fulfill()
                }
            }
        }
        
        
        let r = Request(url: "https://cdn.shopify.com/s/files/1/0229/5765/products/fractalized.jpg?v=1467082024", parser: ImageParser())
        Muttley.fetch(request: r) { (image: UIImage?, error) in
            XCTAssertNotNil(image, "image should not be nil")
            XCTAssertNil(error, "error should be nil")
            latch -= 1
        }
        
        let r2 = Request(url: "https://cdn.shopify.com/s/files/1/0229/5765/products/fractalized.jpg?v=1467082024")
        Muttley.fetch(request: r2) { (data: Data?, error) in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            latch -= 1
        }
    
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func testProgress() {
        
        let ex = expectation(description: "Progress")
        let r = Request(url: "https://web4host.net/20MB.zip", progressHandler: { progress in
            if progress == 1 { ex.fulfill() }
        })
        
        Muttley.fetch(request: r) { (data: Data?, error) in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    
    func testCache() {
        
        let ex = expectation(description: "Cache")
        let r = Request(url: "https://web4host.net/20MB.zip")
        
        Muttley.fetch(request: r) { (data: Data?, error) in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            
            // The second request shouldn't take even fraction of a second, but will take several seconds if not loaded from the cache
            let time = NSDate().timeIntervalSince1970
            Muttley.fetch(request: r, completion: { (data: Data?, error) in
                if NSDate().timeIntervalSince1970 - time < 1 {
                    ex.fulfill()
                } else {
                    XCTFail()
                }
            })
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func testCacheSizeChange() {
        
        let ex = expectation(description: "Cache size change")
        let r = Request(url: "https://web4host.net/20MB.zip")
        
        Muttley.fetch(request: r) { (data: Data?, error) in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            
            // This should clear the cache, since the stored data is larger
            Muttley.maxCapacity = data!.count - 1
            
            //
            let time = NSDate().timeIntervalSince1970
            Muttley.fetch(request: r, completion: { (data: Data?, error) in
                XCTAssertNotNil(data, "data should not be nil")
                XCTAssertNil(error, "error should be nil")
                
                if NSDate().timeIntervalSince1970 - time > 1 {
                    ex.fulfill()
                } else {
                    XCTFail()
                }
            })
        }
        
        waitForExpectations(timeout: 60) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
   
    
    func testCancel() {
        
        let ex = expectation(description: "Cancel")
        let r = Request(url: "https://web4host.net/20MB.zip")
        
        Muttley.fetch(request: r) { (data: Data?, error) in
            XCTAssertNil(data, "data should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            if case .cancelled = error! {
                ex.fulfill()
            } else {
                XCTFail()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Muttley.cancel(request: r)
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func testCancelOneOfManyForIdenticalURL() {
        
        let ex = expectation(description: "Cancel one of many")
        
        let r = Request(url: "https://web4host.net/20MB.zip")
        Muttley.fetch(request: r) { (data: Data?, error) in
            XCTAssertNil(data, "data should be nil")
            XCTAssertNotNil(error, "error should not be nil")
        }
        
        let r2 = Request(url: "https://web4host.net/20MB.zip")
        Muttley.fetch(request: r2) { (data: Data?, error) in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            ex.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Muttley.cancel(request: r)
        }
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
