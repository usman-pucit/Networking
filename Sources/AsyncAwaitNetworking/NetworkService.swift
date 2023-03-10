//
//  NetworkingService.swift
//
//
//  Created by Muhammad Usman on 10/03/2023.
//

import Foundation

@available(iOS 15.0.0, *)
public protocol NetworkServiceProvider {
    func execute<T: Decodable>(request: Request) async throws -> T
}

@available(iOS 15.0, *)
public class NetworkingService {
    // MARK: - Type

    enum NetworkServiceError: Error {
        case invalidResponse
        case unacceptableStatusCode(Int)
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public API

    deinit {
        session.invalidateAndCancel()
    }

    public func execute<T: Decodable>(request: Request) async throws -> T {
        let (data, response) = try await session.data(for: request.urlRequest())

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkServiceError.invalidResponse
        }

        // Validate status code
        guard 200 ... 300 ~= httpResponse.statusCode else {
            throw NetworkServiceError.unacceptableStatusCode(httpResponse.statusCode)
        }

        return try request.decoder.decode(T.self, from: data)
    }
}
