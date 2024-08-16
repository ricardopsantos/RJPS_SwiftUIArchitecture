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

    //
    // MARK: - Default
    //
    typealias ResponseCachedRequest = AnyPublisher<
        ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    func cachedRequest(cachePolicy: Common.CachePolicy) -> ResponseCachedRequest {
        let codableCacheManager = Common_SimpleCacheManagerForCodable.shared
        //
        let serviceKey = #function
        let requestDto = RequestDto.Employee(someParam: "aaa")
        let apiRequest = webAPI.sampleRequestJSON(requestDto)
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
    // MARK: - JSON
    //
    
    func jsonExample(completion:()->(String)) {
        let requestDto = RequestDto.Employee(someParam: "aaa")
        webAPI.sampleRequestJSON(requestDto).sink { _ in } receiveValue: { response in
            Common_Logs.debug(response.data.prefix(3))
        }.store(in: TestsGlobal.cancelBag)
    }

    //
    // MARK: - Task await
    //
    func taskAwait() {
        //
        // Task + wait with CSV result
        Task(priority: .background) {
            do {
                let requestAsyncDto = RequestDto.Employee(someParam: "aaa")
                let response = try await webAPI.sampleRequestCVSAsync(requestAsyncDto)
                Common_Logs.debug("\(response)")
            } catch {
                Common_Logs.error(error)
            }
        }
    }

    //
    // MARK: - SSL Pinning
    //
    static func sslPining() {
        /// https://www.ssllabs.com/ssltest/analyze.html?d=www.google.co.uk&s=2607%3af8b0%3a4007%3a815%3a0%3a0%3a0%3a2003
        let serverPublicHashKey1 = "jr9L2wQM+Sxb3eq5qlk85ZtmrdNwW5qAbGFweZfG6Zw="
        let serverPublicHashKey2 = "2PC8qER2ONKfBHNYFULYdQPSRSjkgxY/eoB5nes/qS4="
        let serverPublicHashKeys = [serverPublicHashKey1, serverPublicHashKey2]
        let networkAgent = SampleWebAPI(
            session: .defaultForNetworkAgent,
            serverPublicHashKeys: serverPublicHashKeys
        )

        let pathToCertificates = [Bundle.main.path(forResource: "google", ofType: "cer")!]
        let apiPinningV2 = SampleWebAPI(
            session: .defaultForNetworkAgent,
            pathToCertificates: pathToCertificates
        )

        let requestAsyncDto = RequestDto.Pinning(someParam: "aaa")

        networkAgent.sampleRequestPinningGoogle(requestAsyncDto)
            .sink { _ in } receiveValue: { response in
                Common_Logs.debug(response)
            }.store(in: TestsGlobal.cancelBag)

        apiPinningV2.sampleRequestPinningGoogle(requestAsyncDto)
            .sink { _ in } receiveValue: { response in
                Common_Logs.debug(response)
            }.store(in: TestsGlobal.cancelBag)
    }
}
