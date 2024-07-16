import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A parser for extracting OpenGraph metadata from HTML content.
///
/// The `OpenGraphParser` class provides methods to parse OpenGraph metadata from various sources,
/// including URLs, URL strings, URLRequests, and raw HTML content. It extracts common OpenGraph
/// properties such as title, type, URL, image, and description.
///
/// OpenGraph is a protocol that enables any web page to become a rich object in a social graph.
/// It is used by social media platforms and other services to extract meaningful information
/// from web pages.
///
/// # Usage Examples
///
/// ## Parsing from a URL
///
/// ```swift
/// let parser = OpenGraphParser()
/// do {
///     let url = URL(string: "https://www.example.com")!
///     let metadata = try await parser.parse(url: url)
///     print("Title: \(metadata.title ?? "N/A")")
///     print("Description: \(metadata.description ?? "N/A")")
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
///
/// ## Parsing from a URL string
///
/// ```swift
/// let parser = OpenGraphParser()
/// do {
///     let metadata = try await parser.parse(urlString: "https://www.example.com")
///     print("Type: \(metadata.type ?? "N/A")")
///     print("Image URL: \(metadata.image?.absoluteString ?? "N/A")")
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
///
/// ## Parsing from a URLRequest
///
/// ```swift
/// let parser = OpenGraphParser()
/// do {
///     var request = URLRequest(url: URL(string: "https://www.example.com")!)
///     request.addValue("MyApp/1.0", forHTTPHeaderField: "User-Agent")
///     let metadata = try await parser.parse(urlRequest: request)
///     print("URL: \(metadata.url?.absoluteString ?? "N/A")")
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
///
/// ## Parsing from an HTML string
///
/// ```swift
/// let parser = OpenGraphParser()
/// do {
///     let html = """
///     <html>
///     <head>
///     <meta property="og:title" content="Example Title">
///     <meta property="og:description" content="This is an example description.">
///     </head>
///     <body>Page content</body>
///     </html>
///     """
///     let metadata = try parser.parse(html: html)
///     print("Title: \(metadata.title ?? "N/A")")
///     print("Description: \(metadata.description ?? "N/A")")
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
///
public final class OpenGraphParser {
    private let urlSession: URLSession
    
    /// Initializes a new instance of OpenGraphParser.
    ///
    /// - Parameter urlSession: The URLSession to use for network requests.
    ///   Defaults to `URLSession.shared`.
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    /// Parses OpenGraph metadata from a given URL.
    ///
    /// This method fetches the content from the provided URL and extracts the OpenGraph metadata.
    ///
    /// - Parameter url: The URL to parse.
    /// - Returns: An `OpenGraphMetadata` object containing the extracted metadata.
    /// - Throws: `OpenGraphParserError.networkError` if there's an issue with the network request.
    ///           `OpenGraphParserError.parsingError` if the content can't be parsed.
    public func parse(url: URL) async throws -> OpenGraphMetadata {
        let (data, _) = try await urlSession.asyncData(from: url)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw OpenGraphParserError.parsingError("Unable to convert data to string")
        }
        return try parse(html: htmlString)
    }
    
    /// Parses OpenGraph metadata from a given URL string.
    ///
    /// This method creates a URL from the provided string, fetches the content,
    /// and extracts the OpenGraph metadata.
    ///
    /// - Parameter urlString: The URL string to parse.
    /// - Returns: An `OpenGraphMetadata` object containing the extracted metadata.
    /// - Throws: `OpenGraphParserError.invalidURL` if the URL string is invalid.
    ///           `OpenGraphParserError.networkError` if there's an issue with the network request.
    ///           `OpenGraphParserError.parsingError` if the content can't be parsed.
    public func parse(urlString: String) async throws -> OpenGraphMetadata {
        guard let url = URL(string: urlString), url.scheme != nil else {
            throw OpenGraphParserError.invalidURL
        }
        return try await parse(url: url)
    }
    
    /// Parses OpenGraph metadata using a custom URLRequest.
    ///
    /// This method allows for more control over the HTTP request by using a custom URLRequest.
    /// It fetches the content using the provided request and extracts the OpenGraph metadata.
    ///
    /// - Parameter urlRequest: The URLRequest to use for fetching the content.
    /// - Returns: An `OpenGraphMetadata` object containing the extracted metadata.
    /// - Throws: `OpenGraphParserError.networkError` if there's an issue with the network request.
    ///           `OpenGraphParserError.parsingError` if the content can't be parsed.
    public func parse(urlRequest: URLRequest) async throws -> OpenGraphMetadata {
        let (data, _) = try await urlSession.asyncData(for: urlRequest)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw OpenGraphParserError.parsingError("Unable to convert data to string")
        }
        return try parse(html: htmlString)
    }
    
    /// Parses OpenGraph metadata from a given HTML string.
    ///
    /// This method extracts OpenGraph metadata directly from an HTML string.
    /// It's useful when you already have the HTML content and don't need to fetch it from a URL.
    ///
    /// - Parameter html: The HTML string to parse.
    /// - Returns: An `OpenGraphMetadata` object containing the extracted metadata.
    /// - Throws: `OpenGraphParserError.parsingError` if the content can't be parsed.
    public func parse(html: String) throws -> OpenGraphMetadata {
        let metaTags = try extractMetaTags(from: html)
        var metadata = OpenGraphMetadata()
        
        for tag in metaTags {
            if let property = tag["property"], let content = tag["content"] {
                switch property {
                case "og:title":
                    metadata = OpenGraphMetadata(
                        title: content,
                        type: metadata.type,
                        url: metadata.url,
                        image: metadata.image,
                        description: metadata.description
                    )
                case "og:type":
                    metadata = OpenGraphMetadata(
                        title: metadata.title,
                        type: content,
                        url: metadata.url,
                        image: metadata.image,
                        description: metadata.description
                    )
                case "og:url":
                    if let url = URL(string: content), url.scheme != nil {
                        metadata = OpenGraphMetadata(
                            title: metadata.title,
                            type: metadata.type,
                            url: url,
                            image: metadata.image,
                            description: metadata.description
                        )
                    }
                case "og:image":
                    if let imageURL = URL(string: content), imageURL.scheme != nil {
                        metadata = OpenGraphMetadata(
                            title: metadata.title,
                            type: metadata.type,
                            url: metadata.url,
                            image: imageURL,
                            description: metadata.description
                        )
                    }
                case "og:description":
                    metadata = OpenGraphMetadata(
                        title: metadata.title,
                        type: metadata.type,
                        url: metadata.url,
                        image: metadata.image,
                        description: content
                    )
                default:
                    break
                }
            }
        }
        
        return metadata
    }
    
    private func extractMetaTags(from html: String) throws -> [[String: String]] {
        let pattern = #"<meta\s+property="(og:[^"]+)"\s+content="([^"]+)"\s*/?>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            throw OpenGraphParserError.parsingError("Failed to create regular expression")
        }
        
        let matches = regex.matches(in: html, options: [], range: NSRange(html.startIndex..., in: html))
        
        return matches.compactMap { match in
            guard let propertyRange = Range(match.range(at: 1), in: html),
                  let contentRange = Range(match.range(at: 2), in: html) else {
                return nil
            }
            
            let property = String(html[propertyRange])
            let content = String(html[contentRange])
            
            return ["property": property, "content": content]
        }
    }
}


enum URLSessionAsyncErrors: Swift.Error {
    case invalidUrlResponse
    case missingResponseData
}

extension URLSession {
 
    /// A reimplementation of `URLSession.shared.data(from: url)` required for Linux
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Returns: Data and response.
    ///
    /// - Usage:
    ///
    ///     let (data, response) = try await URLSession.shared.asyncData(from: url)
    func asyncData(from url: URL) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    continuation.resume(throwing: URLSessionAsyncErrors.invalidUrlResponse)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: URLSessionAsyncErrors.missingResponseData)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
    
    func asyncData(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    continuation.resume(throwing: URLSessionAsyncErrors.invalidUrlResponse)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: URLSessionAsyncErrors.missingResponseData)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}
