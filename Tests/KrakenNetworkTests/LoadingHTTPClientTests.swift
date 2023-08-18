//
//  Copyright © 2023 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import KrakenNetwork
import XCTest

final class LoadingHTTPClientTests: XCTestCase {
    override func tearDown() {
        super.tearDown()

        URLProtocolStub.removeStub()
    }

    func test_request_performsGETRequestWithURL() async throws {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.stub(
            data: nil,
            response: HTTPURLResponse(statusCode: 201),
            error: nil
        ) { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        let sut = try await makeSUT().request(url)
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertEqual(sut.response.statusCode, 201)
    }

    func test_request_failsOnRequestError() async {
        await resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil))
        await resultErrorFor((data: anyData(), response: nil, error: anyNSError()))
        await resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        await resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        await resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        await resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        await resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }

    func test_requestPullback() async throws {
        URLProtocolStub.stub(data: nil, response: HTTPURLResponse(statusCode: 201), error: nil)

        _ = try await makeSUT()
            .pullback(\.url)
            .request((date: Date(), url: anyURL()))
    }

    func test_requestMap() async throws {
        URLProtocolStub.stub(data: anyData(), response: anyHTTPURLResponse(), error: nil)

        let result = try await makeSUT()
            .map(\.data)
            .request(anyURL())

        XCTAssertEqual(result, anyData())
    }

    func test_replaceNilRequest() async throws {
        URLProtocolStub.stub(data: nil, response: anyHTTPURLResponse(), error: nil)

        let result = try await makeSUT()
            .map { $0 }
            .optional()
            .request(anyURL())

        XCTAssertNotNil(result.unsafelyUnwrapped)
    }

    // MARK: - Helpers

    private func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> LoadingHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return httpClient(session: session)
    }

    private func resultErrorFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            let result = try await resultFor(values, file: file, line: line)
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
        } catch {}
    }

    private func resultFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?)?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> HTTPClientResponse {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        let sut = makeSUT(file: file, line: line)
        return try await sut.request(anyURL())
    }
}
