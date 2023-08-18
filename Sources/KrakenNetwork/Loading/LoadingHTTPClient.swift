//
//  Copyright © 2023 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public typealias LoadingHTTPClient = Loading<URL, HTTPClientResponse>

public func httpClient(session: URLSession = .shared) -> LoadingHTTPClient {
    Loading<URL, HTTPClientResponse> { url in
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await session.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw UnexpectedValuesRepresentation()
        }
        return HTTPClientResponse(data: data, response: response)
    }
}

private class UnexpectedValuesRepresentation: Error {}

public struct HTTPClientResponse {
    public let data: Data
    public let response: HTTPURLResponse

    public func map<B>(_ f: @escaping (Self) throws -> B) throws -> B {
        try f(self)
    }

    public func validatingStatusCode(code: Int = 200) throws -> HTTPClientResponse {
        guard response.statusCode == code else {
            throw HTTPClientError.invalidStatusCode(response.statusCode)
        }
        return self
    }
}

public enum HTTPClientError: Error {
    case decodingError(String)
    case invalidStatusCode(Int)
}
