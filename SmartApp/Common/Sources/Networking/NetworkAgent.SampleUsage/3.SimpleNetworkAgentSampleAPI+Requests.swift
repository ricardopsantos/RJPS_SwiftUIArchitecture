//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import CryptoKit

//
// MARK: - NetworkAgentSampleNamespace
//

public extension SimpleNetworkAgentSampleAPI {
    typealias SampleRequestJSONResponse = AnyPublisher<
        NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    func sampleRequestJSON(_ requestDto: NetworkAgentSampleNamespace.RequestDto.Employee) -> SampleRequestJSONResponse {
        // swiftlint:disable redundant_discardable_let
        let /* httpBody */ _ = [
            "publicKey": requestDto.someParam
        ]
        let /* headerValues */ _ = [
            "userId": requestDto.someParam
        ]
        // swiftlint:enable redundant_discardable_let

        let request = CommonNetworking.NetworkAgentRequest(
            path: "raw/8f0f03e6bdfe0dd522ff494022f3aa7a676e882f/Article_13_G8.json",
            queryItems: nil,
            httpMethod: .get,
            httpBody: nil,
            headerValues: nil,
            serverURL: "https://gist.githubusercontent.com/ricardopsantos/10a31da1c6981acd216a93cb040524b9",
            responseType: .json
        )
        return run(
            request: request.urlRequest!,
            decoder: .defaultForWebAPI,
            logger: logger,
            responseType: request.responseFormat
        )
        .flatMap { response in
            Just(response.modelDto).setFailureType(to: CommonNetworking.APIError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    typealias SampleRequestPinningGoogleResponse = AnyPublisher<
        NetworkAgentSampleNamespace.ResponseDto.Pinning,
        CommonNetworking.APIError
    >
    func sampleRequestPinningGoogle(_ requestDto: NetworkAgentSampleNamespace.RequestDto.Pinning) -> SampleRequestPinningGoogleResponse {
        let request = CommonNetworking.NetworkAgentRequest(
            path: "",
            queryItems: nil,
            httpMethod: .get,
            httpBody: nil,
            headerValues: nil,
            serverURL: "https://www.google.co.uk/",
            responseType: .json
        )
        return run(
            request: request.urlRequest!,
            decoder: .defaultForWebAPI,
            logger: logger,
            responseType: request.responseFormat
        )
        .flatMap { response in
            Just(response.modelDto).setFailureType(to: CommonNetworking.APIError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    typealias SampleRequestCVSAsyncResponse = NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability
    func sampleRequestCVSAsync(_ requestDto: NetworkAgentSampleNamespace.RequestDto.Employee) async throws -> SampleRequestCVSAsyncResponse {
        let request = CommonNetworking.NetworkAgentRequest(
            path: "codigos_postais.csv",
            queryItems: nil,
            httpMethod: .get,
            httpBody: nil,
            headerValues: nil,
            serverURL: "https://raw.githubusercontent.com/centraldedados/codigos_postais/master/data",
            responseType: .csv
        )
        return try await runAsync(
            request: request.urlRequest!,
            decoder: .defaultForWebAPI,
            logger: logger,
            responseType: request.responseFormat
        )
    }
}
