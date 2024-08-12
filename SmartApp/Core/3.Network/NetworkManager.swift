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
    public var client = CommonNetworking.NetworkAgent(session: URLSession.defaultWithConfig(
        waitsForConnectivity: false,
        cacheEnabled: false
    ))
    let logger: CommonNetworking.NetworkLogger = .allOn
    var retryDelay: Double {
        5 // session token may take 5s to refresh
    }
}

// MARK: - Requests
extension NetworkManager {
    func request<T: Decodable>(_ api: APIEndpoints, type: T.Type) async throws -> T {
        switch api {
        case .updateUser(user: let user):
            DevTools.assert(false, message: "Not implemented \(user)")
            fatalError()
        default:
            let request = CommonNetworking.NetworkAgentRequest(
                path: api.data.path,
                queryItems: api.urlParameters.map { URLQueryItem(name: $0.key, value: $0.value) },
                httpMethod: api.data.httpMethod,
                httpBody: nil,
                headerValues: nil,
                serverURL: api.data.serverURL,
                responseType: .json
            )
            let cronometerAverageMetricsKey: String = api.name
            CronometerAverageMetrics.shared.start(key: cronometerAverageMetricsKey)
            return try await runAsync(
                request: request.urlRequest!,
                decoder: .defaultForWebAPI,
                logger: logger,
                responseType: request.responseFormat, onCompleted: {
                    CronometerAverageMetrics.shared.end(key: cronometerAverageMetricsKey)
                }
            )
        }
    }
}
