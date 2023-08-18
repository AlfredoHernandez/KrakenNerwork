//
//  Copyright © 2023 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// This protocol represents a task, to cancel any http operations
public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    /// A `GET` HTTP request.
    ///
    /// - Parameters:
    ///     - url: The *url* to perform the request
    ///     - completion: The completion handler to catch the `HTTPClient.Result`.
    ///     The completion handler can be invoked in any thread.
    ///     Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask
}
