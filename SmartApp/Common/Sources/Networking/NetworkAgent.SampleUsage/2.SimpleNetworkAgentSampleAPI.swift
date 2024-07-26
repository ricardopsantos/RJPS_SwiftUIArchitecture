//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
//
public protocol NetworkAgentSampleAPIProtocol {
    func sampleRequestJSON(_ requestDto: NetworkAgentSampleNamespace.RequestDto.Employee) ->
        AnyPublisher<NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability, CommonNetworking.APIError>

    func sampleRequestPinningGoogle(_ requestDto: NetworkAgentSampleNamespace.RequestDto.Pinning) ->
        AnyPublisher<NetworkAgentSampleNamespace.ResponseDto.Pinning, CommonNetworking.APIError>

    func sampleRequestCVSAsync(_ requestDto: NetworkAgentSampleNamespace.RequestDto.Employee) async throws -> NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability
}

public class SimpleNetworkAgentSampleAPI: NSObject, NetworkAgentProtocol, NetworkAgentSampleAPIProtocol {
    private let urlSession: URLSession
    private let authenticationHandler = CommonNetworking.AuthenticationHandler()

    #if targetEnvironment(simulator)
    let logger: CommonNetworking.NetworkLogger = .requestAndResponses
    #else
    let logger: CommonNetworking.NetworkLogger = .allOff
    #endif

    /// No authentication at all
    public init(session: URLSession = URLSession.defaultForNetworkAgent) {
        self.urlSession = URLSession(
            configuration: session.configuration,
            delegate: nil,
            delegateQueue: nil
        )
    }

    /// Basic authentication with user and password,
    public init(
        session: URLSession = URLSession.defaultForNetworkAgent,
        credential: URLCredential
    ) {
        authenticationHandler.credential = credential
        self.urlSession = URLSession(
            configuration: session.configuration,
            delegate: authenticationHandler,
            delegateQueue: nil
        )
    }

    /// SSL Pinning - Using local Public Keys
    public init(
        session: URLSession = URLSession.defaultForNetworkAgent,
        serverPublicHashKeys: [String]
    ) {
        authenticationHandler.serverPublicHashKeys = serverPublicHashKeys
        self.urlSession = URLSession(
            configuration: session.configuration,
            delegate: authenticationHandler,
            delegateQueue: nil
        )
    }

    /// SSL Pinning - Using local stored Certificates
    public init(
        session: URLSession = URLSession.defaultForNetworkAgent,
        pathToCertificates: [String]
    ) {
        authenticationHandler.pathToCertificates = pathToCertificates
        self.urlSession = URLSession(
            configuration: session.configuration,
            delegate: authenticationHandler,
            delegateQueue: nil
        )
    }

    public var client: CommonNetworking.NetworkAgent {
        CommonNetworking.NetworkAgent(session: urlSession)
    }
}
