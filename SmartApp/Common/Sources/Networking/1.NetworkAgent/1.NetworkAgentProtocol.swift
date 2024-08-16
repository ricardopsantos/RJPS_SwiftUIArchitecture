//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

public protocol NetworkAgentProtocol {
    var client: CommonNetworking.NetworkAgentClient { get }
    var logger: CommonNetworking.NetworkLogger { get }
    
    /// Returns `CommonNetworking.Response(modelDto: Decodable, response: Any)`
    func run<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder,
        logger: CommonNetworking.NetworkLogger,
        responseType: CommonNetworking.ResponseFormat,
        onCompleted: @escaping () -> Void
    ) -> AnyPublisher<
        CommonNetworking.Response<T>,
        CommonNetworking.APIError
    >

    func runAsync<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder,
        logger: CommonNetworking.NetworkLogger,
        responseType: CommonNetworking.ResponseFormat,
        onCompleted: @escaping () -> Void
    ) async throws -> T
}

public extension NetworkAgentProtocol {
    func run<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder = .defaultForWebAPI,
        logger: CommonNetworking.NetworkLogger,
        responseType: CommonNetworking.ResponseFormat,
        onCompleted: @escaping () -> Void
    ) -> AnyPublisher<
        CommonNetworking.Response<T>,
        CommonNetworking.APIError
    > where T: Decodable {
        client.run(
            request: request,
            decoder: decoder,
            logger: logger,
            responseFormat: responseType
        )
        .runBlockAndContinue { _ in
            onCompleted()
        }
        .eraseToAnyPublisher()
    }

    func runAsync<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder = .defaultForWebAPI,
        logger: CommonNetworking.NetworkLogger,
        responseType: CommonNetworking.ResponseFormat,
        onCompleted: @escaping () -> Void
    ) async throws -> T {
        try await client.runAsync(
            request: request,
            decoder: decoder,
            logger: logger,
            responseFormat: responseType,
            onCompleted: onCompleted
        )
    }
}
