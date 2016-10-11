![Logo](/Muttley/logo.png?raw=true)

![pod](https://cdn.rawgit.com/zolomatok/Muttley/master/Muttley/pod.svg)
![language](https://cdn.rawgit.com/zolomatok/Muttley/master/Muttley/language.svg)
![platform](https://cdn.rawgit.com/zolomatok/Muttley/master/Muttley/platform.svg)
![license](https://cdn.rawgit.com/zolomatok/Muttley/master/Muttley/license.svg)

Muttley is a lightweight networking library written for Swift.

## Features
- [x] Generic response parsing
- [x] Concurrent requests for the same resource do not start new network request, but each request will be returned with the data
- [x] LRU memory cache with configurable limit
- [x] Cancellable requests
- [x] Progress reporting
- [x] Configurable via URLSessionConfiguration

## Requirement
- iOS 8.0+

## Install
**CocoaPods**

```swift
pod 'Muttley'
```

## How to use

###Fetching###
```swift
let request = Request(url: someURL)
Muttley.fetch(request: request) { [weak self] (data: Data?, error) in

}
```

All but the `url` parameter can be omitted from the `Request` initializer.

*Note the `weak self` in the capture list.*


###Parsing###

```swift
let request = Request(url: someURL, parser: ImageParser())
Muttley.fetch(request: request) { (image: UIImage?, error) in

}
```

You can supply your own parser class that conforms to the simple `Parser` protocol:

```swift
public protocol Parser {
    func parse(data: Data?) -> Any?
}
```

A simple image and JSON parser is provided by the Muttley.


###Progress reporting###

```swift
let request = Request(url: someURL) { [weak self] (progress) in
    self?.progressView.progress = Float(progress)
}
Muttley.fetch(request: request) { (image: UIImage?, error) in

}
```


###Configuration###

We can set the cache size limit of Muttley. Default is `Int.max`.

```swift
Muttley.maxCapacity = Int.max
```

Configuration is possible via `URLSessionConfiguration`.

This makes it possible to use Muttley with any kind of REST API by providing your own header fields.

```swift
let config = URLSessionConfiguration.default
config.httpAdditionalHeaders = ["Authorization": "someKey"]
let request = Request(url: "", configuration: config)
Muttley.fetch(request: request) { (data: Data?, error) in

}
```


## License
Muttley is released under the MIT license. See LICENSE for details.

