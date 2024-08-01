//
//  EmployeeService.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Combine
//
import Domain
import Common

class EmployeeService: EmployeeServiceProtocol {
    func requestEmployeesAsync(_ request: ModelDto.EmployeeRequest) async throws -> ModelDto.EmployeeResponse {
        try await fetchEmployeesAsync(request)
    }

    func requestEmployeesAsPublisher(_ request: ModelDto.EmployeeRequest, cachePolicy: Common.CachePolicy) -> ResponseEmployeesWithCacheMaybe {
        let apiRequest = fetchEmployeesAnyPublisher(request)
        let serviceKey = #function
        let serviceParams: [any Hashable] = [request]
        let apiResponseType = ModelDto.EmployeeResponse.self
        return Common.GenericRequestWithCodableCache.perform(
            apiRequest,
            apiResponseType,
            cachePolicy,
            serviceKey,
            serviceParams,
            60 * 24 * 30, // 1 month
            codableCacheManager
        ).flatMap { modelDto in
            Just(modelDto).setFailureType(to: AppErrors.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func requestEmployeesAsStream(_ requestDto: ModelDto.EmployeeRequest, cachePolicy: Common.CachePolicy) -> ResponseEmployeesWithCacheMaybeAsStream {
        /**
         Usage:
         ```
         Task {
             let employeesUseCase = AppCore.CoreProtocolsResolved.shared.employeesUseCase
             let stream = employeesUseCase.requestEmployeesAsStream(param: "123", cachePolicy: .cacheAndLoad)
             for await result in stream {
                 ("result", Date(), result)
             }
         }
         ```
         */
        requestEmployeesAsPublisher(requestDto, cachePolicy: cachePolicy)
            .errorToNever()
            .stream
    }
}

//
// MARK: Private
//

private extension EmployeeService {
    var codableCacheManager: CodableCacheManagerProtocol {
        Common_SimpleCacheManagerForCodable.shared
    }

    func fetchEmployeesAsync(_ request: ModelDto.EmployeeRequest) async throws -> ModelDto.EmployeeResponse {
        try await NetworkManager.shared.request(
            .requestEmployees(request),
            type: ModelDto.EmployeeResponse.self
        )
    }

    func fetchEmployeesAnyPublisher(_ request: ModelDto.EmployeeRequest) -> ResponseEmployeesWithCacheMaybe {
        let api: APIEndpoints = .requestEmployees(request)
        let request = CommonNetworking.NetworkAgentRequest(
            path: api.data.path,
            queryItems: api.urlParameters.map { URLQueryItem(name: $0.key, value: $0.value) },
            httpMethod: api.data.httpMethod,
            httpBody: nil,
            headerValues: nil,
            serverURL: api.data.serverURL,
            responseType: .json
        )
        typealias APIResponseType = AnyPublisher<
            ModelDto.EmployeeResponse,
            CommonNetworking.APIError
        >
        let apiCall: APIResponseType = NetworkManager.shared.client.run(
            request.urlRequest!,
            .defaultForWebAPI,
            .allOn,
            request.responseFormat
        ).flatMap { response in
            Just(response.modelDto).setFailureType(to: CommonNetworking.APIError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()

        return apiCall
            .mapError { $0.toAppError }.eraseToAnyPublisher()
    }
}
