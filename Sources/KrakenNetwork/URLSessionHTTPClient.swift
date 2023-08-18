//
//  Copyright © 2023 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// A HTTP Client using the `URLSession` Swift's Foundation class
public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    /// - Parameters:
    ///     - session: The *URLSession* required for the client, by default `URLSession.shared`
    public init(session: URLSession = .shared) {
        self.session = session
    }

    private class UnexpectedValuesRepresentation: Error {}

    /// A Wrapper task, like downloading a specific resource, performed in a URL session.
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error {
                    throw error
                } else if let data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task.resume()

        return URLSessionTaskWrapper(wrapped: task)
    }
}
