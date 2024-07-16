import Foundation

/// Errors that can occur during OpenGraph parsing.
public enum OpenGraphParserError: Error {
    /// The provided URL string is invalid.
    case invalidURL
    
    /// An error occurred during network operations.
    case networkError(Error)
    
    /// An error occurred during parsing.
    case parsingError(String)
}
