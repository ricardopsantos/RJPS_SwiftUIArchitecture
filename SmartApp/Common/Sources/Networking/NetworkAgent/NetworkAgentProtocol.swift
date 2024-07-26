//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

public protocol NetworkAgentProtocol {
    var client: CommonNetworking.NetworkAgent { get }

    /// Returns `CommonNetworking.Response(modelDto: Decodable, response: Any)`
    func run<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder,
        logger: CommonNetworking.NetworkLogger,
        responseType: CommonNetworking.ResponseFormat
    ) -> AnyPublisher<
        CommonNetworking.Response<T>,
        CommonNetworking.APIError
    >

    func runAsync<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder,
        logger: CommonNetworking.NetworkLogger,
        responseType: CommonNetworking.ResponseFormat
    ) async throws -> T
}

public extension NetworkAgentProtocol {
    func run<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder = .defaultForWebAPI,
        logger: CommonNetworking.NetworkLogger,
        responseType: CommonNetworking.ResponseFormat
    ) -> AnyPublisher<
        CommonNetworking.Response<T>,
        CommonNetworking.APIError
    > where T: Decodable {
        client.run(
            request,
            decoder,
            logger,
            responseType
        )
        // .runBlockAndContinue { response in
        //    if logger.dumpResponse, let asEncodable = response as? Encodable {
        //        CommonNetworking.handleResponse(request: request, response: asEncodable)
        //    }
        // }
        .eraseToAnyPublisher()
    }

    func runAsync<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder = .defaultForWebAPI,
        logger: CommonNetworking.NetworkLogger,
        responseType: CommonNetworking.ResponseFormat
    ) async throws -> T {
        try await client.runAsync(
            request,
            decoder,
            logger,
            responseType
        )
    }
}
