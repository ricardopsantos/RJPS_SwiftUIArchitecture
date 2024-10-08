//
//  NetworkManager.swift
//  SmartApp
//
//  Created by Ashok Choudhary on 03/01/24.
//  Changed/Updated by Ricardo Santos on 15/04/2024.
//
import Foundation
import Combine
//
import Common
import DevTools

class NetworkManager: NetworkAgentProtocol {
    static var shared = NetworkManager()
    private init() {}
    public var client = CommonNetworking.NetworkAgentClient(session: URLSession.defaultWithConfig(
        waitsForConnectivity: false,
        cacheEnabled: false
    ))
    let defaultLogger: CommonNetworking.NetworkLogger = .allOn
    var retryDelay: Double {
        5 // session token may take 5s to refresh
    }
}

// MARK: - Requests
extension NetworkManager {
    func requestAsync<T: Decodable>(_ api: APIEndpoints) async throws -> T {
        switch api {
        case .updateUser(user: let user):
            DevTools.assert(false, message: "Not implemented \(user)")
            fatalError()
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

    func requestPublisher<T: Decodable>(_ api: APIEndpoints) -> AnyPublisher<T, CommonNetworking.APIError> {
        switch api {
        case .updateUser(user: let user):
            DevTools.assert(false, message: "Not implemented \(user)")
            fatalError()
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
}

//
// MARK: - fileprivate
//
fileprivate extension NetworkManager {
    func buildRequest(api: APIEndpoints) -> CommonNetworking.NetworkAgentRequest {
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
