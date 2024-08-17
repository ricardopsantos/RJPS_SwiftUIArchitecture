//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
@testable import Common
//
// MARK: - Usage
//

public class SampleWebAPIUseCase {
    
    let webAPI: SampleWebAPIProtocol = SampleWebAPI(session: .defaultForNetworkAgent)

    public typealias EmployeesAvailabilityResponse = AnyPublisher<
        ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    
    //
    // MARK: - Simple API Request
    //
    func fetchEmployeesAvailability() -> EmployeesAvailabilityResponse {
        let requestDto = RequestDto.Employee(someParam: "aaa")
        return webAPI.fetchEmployeesAvailability(requestDto)
    }
    
    //
    // MARK: - API Request + Cache
    //
    func fetchEmployeesAvailability(cachePolicy: Common.CachePolicy) -> EmployeesAvailabilityResponse {
        let codableCacheManager = Common_SimpleCacheManagerForCodable.shared
        //
        let serviceKey = #function
        let requestDto = RequestDto.Employee(someParam: "aaa")
        let apiRequest = webAPI.fetchEmployeesAvailability(requestDto)
        let serviceParams: [any Hashable] = [requestDto.someParam]
        let apiResponseType = ResponseDto.EmployeeServiceAvailability.self
        //
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
    // MARK: - API Request + Async
    //
    public typealias SampleRequestCVSAsyncResponse = ResponseDto.EmployeeServiceAvailability
    func fetchEmployeesAvailabilityAsync() async -> SampleRequestCVSAsyncResponse {
        let requestAsyncDto = RequestDto.Employee(someParam: "aaa")
        return try! await webAPI.fetchEmployeesAvailability(requestAsyncDto).async()
    }

    //
    // MARK: - API Request + SSL Pinning (with Certificate)
    //
    func fetchEmployeesAvailabilitySLLCertificate(server: CommonNetworking.AuthenticationHandler.Server) -> EmployeesAvailabilityResponse {
        let webAPISSLPinningWithCertificates = SampleWebAPI(
            session: .defaultForNetworkAgent,
            pathToCertificates: server.pathToCertificates ?? []
        )
        let requestDto = RequestDto.Employee(someParam: "aaa")
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
        let requestDto = RequestDto.Employee(someParam: "aaa")
        return webAPISSLPinningWithCertificates.fetchEmployeesAvailability(requestDto)
    }
}
