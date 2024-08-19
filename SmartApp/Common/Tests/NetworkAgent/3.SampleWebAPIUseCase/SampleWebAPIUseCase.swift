//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
@testable import Common

public class SampleWebAPIUseCase {
    private let webAPI: SampleWebAPIProtocol = SampleWebAPI(session: .defaultForNetworkAgent)
    private let codableCacheManager = Common_SimpleCacheManagerForCodable.shared
    
    public typealias EmployeesAvailabilityResponse = AnyPublisher<
        ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    
    //
    // MARK: - Simple API Requests
    //
    func fetchEmployeesAvailabilityCustom() -> EmployeesAvailabilityResponse {
        let requestDto = RequestDto.Employee(id: UUID().uuidString)
        return webAPI.fetchEmployeesAvailability(requestDto)
    }
    
    func fetchEmployeesPublisher() -> EmployeesAvailabilityResponse {
        let requestDto = RequestDto.Employee(id: UUID().uuidString)
        return webAPI.requestPublisher(.fetchEmployees(requestDto))
    }
    
    func fetchEmployeesAsync() async throws -> ResponseDto.EmployeeServiceAvailability {
        let requestDto = RequestDto.Employee(id: UUID().uuidString)
        return try await webAPI.requestAsync(.fetchEmployees(requestDto))
    }
    
    //
    // MARK: - API Request + Cache
    //
    func fetchEmployees(cachePolicy: Common.CachePolicy) -> EmployeesAvailabilityResponse {
        //
        let serviceKey = #function
        let requestDto = RequestDto.Employee(id: UUID().uuidString)
        let apiRequest: AnyPublisher<
            ResponseDto.EmployeeServiceAvailability,
            CommonNetworking.APIError
        > = webAPI.requestPublisher(.fetchEmployees(requestDto))
        let serviceParams: [any Hashable] = [requestDto.id]
        let apiResponseType = ResponseDto.EmployeeServiceAvailability.self
        return Common.GenericRequestWithCodableCache.perform(
            apiRequest,
            apiResponseType,
            cachePolicy,
            serviceKey,
            serviceParams,
            60 * 24 * 30, // 1 month
            codableCacheManager
        ).eraseToAnyPublisher()
    }
    
    //
    // MARK: - API Request + SSL Pinning (with Certificate)
    //
    func fetchEmployeesAvailabilitySLLCertificate(server: CommonNetworking.AuthenticationHandler.Server) -> EmployeesAvailabilityResponse {
        let webAPISSLPinningWithCertificates = SampleWebAPI(
            session: .defaultForNetworkAgent,
            pathToCertificates: server.pathToCertificates ?? []
        )
        let requestDto = RequestDto.Employee(id: "aaa")
        return webAPISSLPinningWithCertificates.fetchEmployeesAvailability(requestDto)
    }
    
    //
    // MARK: - API Request + SSL Pinning (with Certificate)
    //
    func fetchEmployeesAvailabilitySLLHashKeys(server: CommonNetworking.AuthenticationHandler.Server) -> EmployeesAvailabilityResponse {
        let webAPISSLPinningWithCertificates = SampleWebAPI(
            session: .defaultForNetworkAgent,
            pathToCertificates: server.publicHashKeys
        )
        let requestDto = RequestDto.Employee(id: UUID().uuidString)
        return webAPISSLPinningWithCertificates.fetchEmployeesAvailability(requestDto)
    }
}
