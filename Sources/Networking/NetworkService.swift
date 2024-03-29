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
public class NetworkService {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
}

@available(iOS 15.0, *)
extension NetworkService: NetworkServiceProvider {
    public enum NetworkServiceError: Error {
        case invalidResponse
        case unacceptableStatusCode(Int)
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
