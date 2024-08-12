//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

//
// MARK: - Usage
//

private let cancelBag = CancelBag()
public extension NetworkAgentSampleNamespace {
    typealias ResponseCachedRequest = AnyPublisher<
        NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    static func cachedRequest(cachePolicy: Common.CachePolicy) -> ResponseCachedRequest {
        let codableCacheManager = Common_SimpleCacheManagerForCodable.shared
        let defaultForNetworkAgent: NetworkAgentSampleAPIProtocol = SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
        //
        let serviceKey = #function
        let requestDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
        let apiRequest = defaultForNetworkAgent.sampleRequestJSON(requestDto)
        let serviceParams: [any Hashable] = [requestDto.someParam]
        let apiResponseType = NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability.self
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

    func jsonExample() {
        //
        // JSON
        //
        let defaultForNetworkAgent: NetworkAgentSampleAPIProtocol = SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
        let requestDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
        defaultForNetworkAgent.sampleRequestJSON(requestDto).sink { _ in } receiveValue: { response in
            Common_Logs.debug(response.data.prefix(3))
        }.store(in: cancelBag)
    }

    func taskAwait() {
        //
        // Task + wait with CSV result
        Task(priority: .background) {
            do {
                let defaultForNetworkAgent: NetworkAgentSampleAPIProtocol = SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
                let requestAsyncDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
                let response = try await defaultForNetworkAgent.sampleRequestCVSAsync(requestAsyncDto)
                Common_Logs.debug("\(response)")
            } catch {
                Common_Logs.error(error)
            }
        }
    }

    static func sslPining() {
        //
        // SSL Pinning
        //

        /// https://www.ssllabs.com/ssltest/analyze.html?d=www.google.co.uk&s=2607%3af8b0%3a4007%3a815%3a0%3a0%3a0%3a2003
        let serverPublicHashKey1 = "jr9L2wQM+Sxb3eq5qlk85ZtmrdNwW5qAbGFweZfG6Zw="
        let serverPublicHashKey2 = "2PC8qER2ONKfBHNYFULYdQPSRSjkgxY/eoB5nes/qS4="
        let serverPublicHashKeys = [serverPublicHashKey1, serverPublicHashKey2]
        let apiPinningV1 = SimpleNetworkAgentSampleAPI(
            session: .defaultForNetworkAgent,
            serverPublicHashKeys: serverPublicHashKeys
        )

        let pathToCertificates = [Bundle.main.path(forResource: "google", ofType: "cer")!]
        let apiPinningV2 = SimpleNetworkAgentSampleAPI(
            session: .defaultForNetworkAgent,
            pathToCertificates: pathToCertificates
        )

        let requestAsyncDto = NetworkAgentSampleNamespace.RequestDto.Pinning(someParam: "aaa")

        apiPinningV1.sampleRequestPinningGoogle(requestAsyncDto)
            .sink { _ in } receiveValue: { response in
                Common_Logs.debug(response)
            }.store(in: cancelBag)

        apiPinningV2.sampleRequestPinningGoogle(requestAsyncDto)
            .sink { _ in } receiveValue: { response in
                Common_Logs.debug(response)
            }.store(in: cancelBag)
    }
}
