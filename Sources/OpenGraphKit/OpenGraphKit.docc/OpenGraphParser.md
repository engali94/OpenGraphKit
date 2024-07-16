# ``OpenGraphParser``

The heart of OpenGraphKit, `OpenGraphParser` is a powerful and flexible class designed to extract OpenGraph metadata from various sources.

## Overview

`OpenGraphParser` provides methods to parse OpenGraph metadata from:
- HTML strings
- URLs
- Custom URL requests

It leverages Swift's modern concurrency features for efficient asynchronous operations when fetching content from the web.

## Initialization

```swift
public init(urlSession: URLSession = .shared)
```

Create an instance of `OpenGraphParser` with an optional custom `URLSession`. If not provided, it uses the shared session.

## Key Methods

### Parsing from HTML

```swift
public func parse(html: String) throws -> OpenGraphMetadata
```

This synchronous method parses OpenGraph metadata directly from an HTML string. It's useful when you already have the HTML content and don't need to fetch it from a URL.

#### Example:

```swift
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

### Parsing from URL

```swift
public func parse(url: URL) async throws -> OpenGraphMetadata
```

This asynchronous method fetches the content from the provided URL and extracts the OpenGraph metadata.

#### Example:

```swift
do {
    let url = URL(string: "https://www.example.com")!
    let metadata = try await parser.parse(url: url)
    print("Title: \(metadata.title ?? "N/A")")
    print("Description: \(metadata.description ?? "N/A")")
} catch {
    print("Error: \(error)")
}
```

### Parsing from URL String

```swift
public func parse(urlString: String) async throws -> OpenGraphMetadata
```

This method creates a URL from the provided string, fetches the content, and extracts the OpenGraph metadata.

#### Example:

```swift
do {
    let metadata = try await parser.parse(urlString: "https://www.example.com")
    print("Title: \(metadata.title ?? "N/A")")
    print("Type: \(metadata.type ?? "N/A")")
} catch {
    print("Error: \(error)")
}
```

### Parsing with Custom URLRequest

```swift
public func parse(urlRequest: URLRequest) async throws -> OpenGraphMetadata
```

This method allows for more control over the HTTP request by using a custom URLRequest. It fetches the content using the provided request and extracts the OpenGraph metadata.

#### Example:

```swift
do {
    var request = URLRequest(url: URL(string: "https://www.example.com")!)
    request.addValue("MyApp/1.0", forHTTPHeaderField: "User-Agent")
    let metadata = try await parser.parse(urlRequest: request)
    print("Title: \(metadata.title ?? "N/A")")
    print("Image URL: \(metadata.image?.absoluteString ?? "N/A")")
} catch {
    print("Error: \(error)")
}
```

## Error Handling

All parsing methods can throw `OpenGraphParserError`. See [Error Handling](OpenGraphParserError.md) for more details on possible errors and how to handle them.

## Best Practices

- Use the asynchronous methods (`parse(url:)`, `parse(urlString:)`, `parse(urlRequest:)`) when fetching content from the web to avoid blocking the main thread.
- Handle potential errors gracefully, especially when dealing with network requests.
- Consider implementing retry logic for network-related errors.
- Use a custom `URLSession` if you need to configure specific networking behavior (e.g., caching policies, timeout intervals).

## Performance Considerations

- The parser uses regular expressions to extract metadata, which is generally fast but can be slower for very large HTML documents.
- For best performance when parsing multiple URLs, consider using Swift's concurrency features like `async let` or `TaskGroup` to parallelize the requests.

By leveraging `OpenGraphParser`, you can easily integrate rich web content previews into your Swift applications, enhancing the user experience with minimal effort.

