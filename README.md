# OpenGraphKit
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F[yourusername]%2FOpenGraphKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/engali94/OpenGraphKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F[yourusername]%2FOpenGraphKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/engali94/OpenGraphKit)
OpenGraphKit is a Swift package that provides an easy way to parse OpenGraph metadata from HTML content, URLs, and URL requests. Compatible with both Apple platforms and Linux.

## Features

- Parse OpenGraph metadata from HTML strings
- Fetch and parse OpenGraph metadata from URLs
- Support for custom URL requests
- Asynchronous API using Swift concurrency
- Cross-platform support (Apple platforms and Linux)

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/engali94/OpenGraphKit.git", from: "0.1")
]
```
To integrate OpenGraphKit into your Xcode project using Swift Package Index, follow these steps:

1. In Xcode, select "File" → "Add Packages..."
2. Enter the URL: `https://github.com/[yourusername]/OpenGraphKit.git`
3. Select the version rule that fits your needs (e.g., "Up to Next Major" for automatic updates to new versions)
4. Click "Add Package"

You can also visit our [Swift Package Index page](https://swiftpackageindex.com/engali94/OpenGraphKit) for more information, alternative integration methods, and to view the generated documentation.


## Usage

All properties are optional, as not all OpenGraph metadata may be present in every page.

### Parsing from HTML

```swift
import OpenGraphKit

let parser = OpenGraphParser()
let html = """
<html>
<head>
<meta property="og:title" content="Example Title">
<meta property="og:description" content="This is an example description.">
</head>
<body>Page content</body>
</html>
"""

do {
    let metadata = try parser.parse(html: html)
    print("Title: \(metadata.title ?? "N/A")")
    // ... print other metadata properties
} catch {
    print("Error: \(error)")
}
```

### Parsing from URL

```swift
import OpenGraphKit

let parser = OpenGraphParser()
let url = URL(string: "https://example.com")!

do {
    let metadata = try await parser.parse(url: url)
    print("Title: \(metadata.title ?? "N/A")")
    // ... print other metadata properties

} catch {
    print("Error: \(error)")
}
```

### Parsing with Custom URLRequest

```swift
import OpenGraphKit

let parser = OpenGraphParser()
var request = URLRequest(url: URL(string: "https://example.com")!)
do {
    let metadata = try await parser.parse(urlRequest: request)
    print("Title: \(metadata.title ?? "N/A")")
    // ... print other metadata properties
} catch {
    print("Error: \(error)")
}
```

## Contributing

Contributions to OpenGraphKit are welcome! Please feel free to submit a Pull Request.

## License

OpenGraphKit is released under the MIT license. See LICENSE for details.
