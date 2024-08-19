//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import CryptoKit
@testable import Common

//
// MARK: - SampleWebAPIProtocol
//
extension SampleWebAPI: SampleWebAPIProtocol {
    //
    // MARK: - Generic api calls
    //
    public func requestAsync<T: Decodable>(_ api: SampleWebAPIMethods) async throws -> T {
        switch api {
        case .updateEmployee:
            // Custom implementation (if needed)
            fatalError("Not implemented")
        default:
            let request = buildRequest(api: api)
            let cronometerAverageMetricsKey: String = api.name
            CronometerAverageMetrics.shared.start(key: cronometerAverageMetricsKey)
            return try await runAsync(
                request: request.urlRequest!,
                decoder: .defaultForWebAPI,
                logger: defaultLogger,
                responseType: request.responseFormat, onCompleted: {
                    CronometerAverageMetrics.shared.end(key: cronometerAverageMetricsKey)
                }
            )
        }
    }
    
    public func requestPublisher<T: Decodable>(_ api: SampleWebAPIMethods) -> AnyPublisher<T, CommonNetworking.APIError> {
        switch api {
        case .updateEmployee:
            // Custom implementation (if needed)
            fatalError("Not implemented")
        default:
            let request = buildRequest(api: api)
            let cronometerAverageMetricsKey: String = api.name
            CronometerAverageMetrics.shared.start(key: cronometerAverageMetricsKey)
            return run(
                request: request.urlRequest!,
                decoder: .defaultForWebAPI,
                logger: defaultLogger,
                responseType: request.responseFormat,
                onCompleted: {
                    CronometerAverageMetrics.shared.start(key: cronometerAverageMetricsKey)
                }
            )
            .flatMap { response in
                Just(response.modelDto).setFailureType(to: CommonNetworking.APIError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
    }
    
    //
    // MARK: - Verbose/Custom api calls
    //
    public typealias EmployeesAvailabilityResponse = AnyPublisher<
        ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    public func fetchEmployeesAvailability(_ requestDto: RequestDto.Employee) -> EmployeesAvailabilityResponse {
        let request = CommonNetworking.NetworkAgentRequest(
            path: "raw/8f0f03e6bdfe0dd522ff494022f3aa7a676e882f/Article_13_G8.json",
            queryItems: nil,
            httpMethod: .get,
            httpBody: nil,
            headerValues: nil,
            serverURL: "https://gist.githubusercontent.com/ricardopsantos/10a31da1c6981acd216a93cb040524b9",
            responseType: .json
        )
        let cronometerAverageMetricsKey = #function
        CronometerAverageMetrics.shared.start(key: #function)
        return run(
            request: request.urlRequest!,
            decoder: .defaultForWebAPI,
            logger: defaultLogger,
            responseType: request.responseFormat,
            onCompleted: {
                CronometerAverageMetrics.shared.start(key: cronometerAverageMetricsKey)
            }
        )
        .flatMap { response in
            Just(response.modelDto).setFailureType(to: CommonNetworking.APIError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

//
// MARK: - SampleWebAPIProtocol
//
fileprivate extension SampleWebAPI {
    private func buildRequest(api: SampleWebAPIMethods) -> CommonNetworking.NetworkAgentRequest {
        .init(
            path: api.data.path,
            queryItems: api.queryItems.map { URLQueryItem(name: $0.key, value: $0.value) },
            httpMethod: api.data.httpMethod,
            httpBody: api.httpBody,
            headerValues: api.headerValues,
            serverURL: api.data.serverURL,
            responseType: api.responseType
        )
    }
}
