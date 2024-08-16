//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import Security
import CommonCrypto

public extension CommonNetworking {
    class NetworkAgent: NSObject, URLSessionDelegate {
        let urlSession: URLSession
        private var authenticationHandler: CommonNetworking.AuthenticationHandler?
        
        /// No authentication at all
        public init(session: URLSession) {
            self.urlSession = URLSession(
                configuration: session.configuration,
                delegate: nil,
                delegateQueue: nil)
        }

        /// Basic authentication with user and password,
        public init(
            session: URLSession,
            credential: URLCredential) {
                authenticationHandler = .init()
                authenticationHandler?.credential = credential
            self.urlSession = URLSession(
                configuration: session.configuration,
                delegate: authenticationHandler,
                delegateQueue: nil)
        }

        /// SSL Pinning - Using local Public Keys
        public init(
            session: URLSession,
            serverPublicHashKeys: [String]) {
                authenticationHandler = .init()
            authenticationHandler?.serverPublicHashKeys = serverPublicHashKeys
            self.urlSession = URLSession(
                configuration: session.configuration,
                delegate: authenticationHandler,
                delegateQueue: nil)
        }

        /// SSL Pinning - Using local stored Certificates
        public init(
            session: URLSession,
            pathToCertificates: [String]) {
                authenticationHandler = .init()
                authenticationHandler?.pathToCertificates = pathToCertificates
            self.urlSession = URLSession(
                configuration: session.configuration,
                delegate: authenticationHandler,
                delegateQueue: nil)
        }


    }
}

