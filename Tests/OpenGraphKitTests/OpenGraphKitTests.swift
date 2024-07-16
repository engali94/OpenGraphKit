import XCTest
@testable import OpenGraphKit

final class OpenGraphParserTests: XCTestCase {
    var parser: OpenGraphParser!
    var mockSession: MockURLSession!
    
    override func setUpWithError() throws {
        mockSession = MockURLSession()
        parser = OpenGraphParser(urlSession: mockSession)
    }
    
    override func tearDownWithError() throws {
        parser = nil
        mockSession = nil
    }
}

// MARK: - HTML Parsing Tests
extension OpenGraphParserTests {
    func testParseHTML_WithAllTags_ShouldReturnCompleteMetadata() throws {
        let html = createHTML(tags: [
            ("og:title", "Test Title"),
            ("og:type", "website"),
            ("og:url", "https://example.com"),
            ("og:image", "https://example.com/image.jpg"),
            ("og:description", "Test Description")
        ])
        
        let metadata = try parser.parse(html: html)
        
        assertMetadata(metadata, matches: [
            .title("Test Title"),
            .type("website"),
            .url("https://example.com"),
            .image("https://example.com/image.jpg"),
            .description("Test Description")
        ])
    }
    
    func testParseHTML_WithMissingTags_ShouldReturnPartialMetadata() throws {
        let html = createHTML(tags: [
            ("og:title", "Test Title"),
            ("og:description", "Test Description")
        ])
        
        let metadata = try parser.parse(html: html)
        
        assertMetadata(metadata, matches: [
            .title("Test Title"),
            .type(nil),
            .url(nil),
            .image(nil),
            .description("Test Description")
        ])
    }
    
    func testParseHTML_WithInvalidURLs_ShouldIgnoreInvalidURLs() throws {
        let html = createHTML(tags: [
            ("og:title", "Test Title"),
            ("og:url", "invalid-url"),
            ("og:image", "invalid-image-url")
        ])
        
        let metadata = try parser.parse(html: html)
        
        assertMetadata(metadata, matches: [
            .title("Test Title"),
            .url(nil),
            .image(nil)
        ])
    }
}

// MARK: - URL Parsing Tests
extension OpenGraphParserTests {
    func testParseURL_WithValidMetadata_ShouldReturnCorrectMetadata() async throws {
        let url = URL(string: "https://example.com")!
        mockSession.data = createHTML(tags: [
            ("og:title", "Example Domain"),
            ("og:type", "website"),
            ("og:url", "https://example.com")
        ]).data(using: .utf8)!
        
        let metadata = try await parser.parse(url: url)
        
        assertMetadata(metadata, matches: [
            .title("Example Domain"),
            .type("website"),
            .url("https://example.com")
        ])
    }
    
    func testParseURLString_WithValidMetadata_ShouldReturnCorrectMetadata() async throws {
        let urlString = "https://example.com"
        mockSession.data = createHTML(tags: [
            ("og:title", "Example Domain"),
            ("og:description", "This is an example website.")
        ]).data(using: .utf8)!
        
        let metadata = try await parser.parse(urlString: urlString)
        
        assertMetadata(metadata, matches: [
            .title("Example Domain"),
            .description("This is an example website.")
        ])
    }
    
    func testParseURLRequest_WithValidMetadata_ShouldReturnCorrectMetadata() async throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.addValue("MyApp/1.0", forHTTPHeaderField: "User-Agent")
        
        mockSession.data = createHTML(tags: [
            ("og:title", "Example Domain"),
            ("og:image", "https://example.com/image.jpg")
        ]).data(using: .utf8)!
        
        let metadata = try await parser.parse(urlRequest: request)
        
        assertMetadata(metadata, matches: [
            .title("Example Domain"),
            .image("https://example.com/image.jpg")
        ])
    }
    
    func testParseURLString_WithInvalidURL_ShouldThrowError() async {
        do {
            _ = try await parser.parse(urlString: "random string")
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertTrue(error is OpenGraphParserError)
        }
    }
}

// MARK: - Helper Methods
extension OpenGraphParserTests {
    func createHTML(tags: [(String, String)]) -> String {
        let metaTags = tags.map { "<meta property=\"\($0)\" content=\"\($1)\">" }.joined(separator: "\n")
        return """
        <html>
        <head>
        \(metaTags)
        </head>
        <body>Page content</body>
        </html>
        """
    }
    
    enum Expectation {
        case title(String?)
        case type(String?)
        case url(String?)
        case image(String?)
        case description(String?)
        
        func assert(_ metadata: OpenGraphMetadata, file: StaticString = #file, line: UInt = #line) {
            switch self {
            case .title(let expected):
                XCTAssertEqual(metadata.title, expected, "Title mismatch", file: file, line: line)
            case .type(let expected):
                XCTAssertEqual(metadata.type, expected, "Type mismatch", file: file, line: line)
            case .url(let expected):
                XCTAssertEqual(metadata.url?.absoluteString, expected, "URL mismatch", file: file, line: line)
            case .image(let expected):
                XCTAssertEqual(metadata.image?.absoluteString, expected, "Image URL mismatch", file: file, line: line)
            case .description(let expected):
                XCTAssertEqual(metadata.description, expected, "Description mismatch", file: file, line: line)
            }
        }
    }
    
    func assertMetadata(_ metadata: OpenGraphMetadata, matches expectations: [Expectation], file: StaticString = #file, line: UInt = #line) {
        for expectation in expectations {
            expectation.assert(metadata, file: file, line: line)
        }
    }
}

final class MockURLSession: URLSession {
    var data: Data = Data()
    var error: Error?
    var response: URLResponse = HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!

    override func dataTask(
        with url: URL,
        completionHandler: @escaping (
            Data?,
            URLResponse?,
            Error?
        ) -> Void
    ) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            if let error = self.error {
                completionHandler(nil, nil, error)
            } else {
                completionHandler(self.data, self.response, nil)
            }
        }
    }

    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (
            Data?,
            URLResponse?,
            Error?
        ) -> Void
    ) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            if let error = self.error {
                completionHandler(nil, nil, error)
            } else {
                completionHandler(self.data, self.response, nil)
            }
        }
    }
}

final class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}
