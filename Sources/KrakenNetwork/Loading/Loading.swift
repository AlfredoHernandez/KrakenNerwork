//
//  Copyright © 2023 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

public struct Loading<Input, Output> {
    let request: (Input) async throws -> Output

    func pullback<B>(_ f: @escaping (B) -> Input) -> Loading<B, Output> {
        Loading<B, Output> { b in
            try await request(f(b))
        }
    }

    func map<NewResponse>(_ transform: @escaping (Output) throws -> NewResponse) -> Loading<Input, NewResponse> {
        Loading<Input, NewResponse> { a in
            let response = try await request(a)
            return try transform(response)
        }
    }

    func replaceNil<T>(with defaultValue: T) -> Loading<Input, Output> where Output == T? {
        map { $0 ?? defaultValue }
    }

    func asAnyPublisher() -> Loading<Input, AnyPublisher<Output, Error>> {
        Loading<Input, AnyPublisher<Output, Error>> { a in
            let response = try await request(a)
            let publisher = CurrentValueSubject<Output, Error>(response)
            return publisher.eraseToAnyPublisher()
        }
    }

    func optional() -> Loading<Input, Output?> {
        Loading<Input, Output?> { a in
            let response = try await request(a)
            return Optional(response)
        }
    }

    func `catch`(_ handler: @escaping (Error) -> Loading<Input, Output>) -> Loading<Input, Output> {
        Loading<Input, Output> { a in
            do {
                return try await request(a)
            } catch {
                let loading = handler(error)
                return try await loading.request(a)
            }
        }
    }

    func fallback(to fallbackLoading: Loading<Input, Output>) -> Loading<Input, Output> {
        self.catch { _ in fallbackLoading }
    }

    func eraseToAnyLoading() -> Loading<Any, Output> {
        Loading<Any, Output> { input in
            try await request(input as! Input)
        }
    }
}
