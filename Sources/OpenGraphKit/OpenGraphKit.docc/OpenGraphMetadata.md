# ``OpenGraphKit``

OpenGraphKit is a powerful, efficient, and easy-to-use Swift package designed to parse OpenGraph metadata from HTML content, URLs, and URL requests.

## Overview

Whether you're building a social media app, a content aggregator, or any application that needs to display rich previews of web content, OpenGraphKit has got you covered.

## Features

- 🚀 **Swift-first**: Built from the ground up with Swift's modern features.
- 🌐 **Cross-platform**: Seamlessly works on iOS, macOS, tvOS, watchOS, and Linux.
- ⚡️ **Asynchronous API**: Leverages `async/await` for efficient network operations.
- 🧩 **Flexible Parsing**: Extract metadata from HTML strings, URLs, or custom URL requests.
- 🛡 **Robust Error Handling**: Comprehensive error types for graceful failure management.
- 🧪 **Thoroughly Tested**: Extensive test suite ensures reliability and correctness.

## Quick Start

```swift
import OpenGraphKit

let parser = OpenGraphParser()

// Parse from a URL
do {
    let url = URL(string: "https://www.example.com")!
    let metadata = try await parser.parse(url: url)
    print("Title: \(metadata.title ?? "N/A")")
    print("Description: \(metadata.description ?? "N/A")")
} catch {
    print("Error: \(error)")
}

// Parse from HTML
let html = """
<html><head>
<meta property="og:title" content="Example Title">
<meta property="og:description" content="Example Description">
</head></html>
"""
do {
    let metadata = try parser.parse(html: html)
    print("Title: \(metadata.title ?? "N/A")")
    print("Description: \(metadata.description ?? "N/A")")
} catch {
    print("Error: \(error)")
}
```

## Why OpenGraphKit?

OpenGraph is a protocol that enables any web page to become a rich object in a social graph. It's widely used by social media platforms and other services to extract meaningful information from web pages. OpenGraphKit makes it trivial to harness this power in your Swift applications.

With OpenGraphKit, you can:

- 📱 Create rich link previews in messaging apps
- 🗂 Build sophisticated content aggregators
- 🔍 Enhance search results with detailed metadata
- 🖼 Generate image galleries from web content
- 📊 Analyze and categorize web pages based on their metadata

## Diving Deeper

Explore our comprehensive documentation to learn more about:

- [OpenGraphParser](OpenGraphParser.md): The core class for all your parsing needs.
- [OpenGraphMetadata](OpenGraphMetadata.md): Understanding the structure of parsed metadata.

## Get Involved

We welcome contributions! Whether it's submitting bug reports, proposing new features, or contributing code, check out our [GitHub repository](https://github.com/yourusername/OpenGraphKit) to get started.

## License

OpenGraphKit is released under the MIT license. See [LICENSE](LICENSE) for details.

Start supercharging your app with rich web content today using OpenGraphKit!
