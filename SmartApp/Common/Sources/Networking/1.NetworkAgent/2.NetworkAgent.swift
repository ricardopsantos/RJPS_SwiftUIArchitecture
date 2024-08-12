//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import Security
import CommonCrypto

public extension CommonNetworking {
    //
    // MARK: - NetworkAgent
    //
    class NetworkAgent: NSObject, URLSessionDelegate {
        private let urlSession: URLSession
        private let authenticationHandler = CommonNetworking.AuthenticationHandler()

        /// No authentication at all
        public init(session: URLSession = URLSession.defaultForNetworkAgent) {
            self.urlSession = URLSession(
                configuration: session.configuration,
                delegate: nil,
                delegateQueue: nil)
        }

        /// Basic authentication with user and password,
        public init(
            session: URLSession = URLSession.defaultForNetworkAgent,
            credential: URLCredential) {
            authenticationHandler.credential = credential
            self.urlSession = URLSession(
                configuration: session.configuration,
                delegate: authenticationHandler,
                delegateQueue: nil)
        }

        /// SSL Pinning - Using local Public Keys
        public init(
            session: URLSession = URLSession.defaultForNetworkAgent,
            serverPublicHashKeys: [String]) {
            authenticationHandler.serverPublicHashKeys = serverPublicHashKeys
            self.urlSession = URLSession(
                configuration: session.configuration,
                delegate: authenticationHandler,
                delegateQueue: nil)
        }

        /// SSL Pinning - Using local stored Certificates
        public init(
            session: URLSession = URLSession.defaultForNetworkAgent,
            pathToCertificates: [String]) {
            authenticationHandler.pathToCertificates = pathToCertificates
            self.urlSession = URLSession(
                configuration: session.configuration,
                delegate: authenticationHandler,
                delegateQueue: nil)
        }

        public var client: CommonNetworking.NetworkAgent {
            CommonNetworking.NetworkAgent(session: urlSession)
        }
    }
}

//
// MARK: - WebAPIErrorHandler
//

public extension CommonNetworking {
    @discardableResult
    static func handleResponse(
        request: URLRequest?,
        response: Encodable?) -> String {
        var message: String = ""
        if let url = request?.url {
            message += "ServerURL: \(url.absoluteString)" + "\n"
        }
        if let response {
            message += "\(String(describing: response.toDictionary))"
        }
        Common_Logs.debug(message)
        return message
    }
}

//
// MARK: - Run
//

public extension CommonNetworking.NetworkAgent {
    func run<T>(
        _ request: URLRequest,
        _ decoder: JSONDecoder,
        _ logger: CommonNetworking.NetworkLogger,
        _ responseFormat: CommonNetworking.ResponseFormat) -> AnyPublisher<
        CommonNetworking.Response<T>,
        CommonNetworking.APIError
    > where T: Decodable {
        let cronometerId = request.cronometerId
        let number = logger.number > 0 ? " #\(logger.number)" : ""
        let prefix = logger.prefix.isEmpty ? "" : "\(logger.prefix): "

        if !Common_Utils.existsInternetConnection() {
            Common_Logs.error("⤴️ Request\(number) ⤴️ \(prefix)\(request) : No Internet connection")
        }

        let requestDebug = "\(request) -> \(T.self).type"
        if logger.dumpRequest {}
        return urlSession
            .dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                if logger.logOperationTime {
                    Common.CronometerManager.startTimerWith(identifier: cronometerId)
                }
                if logger.dumpRequest {
                    Common_Logs.debug("⤴️ Request\(number) ⤴️ \(prefix)\(request)")
                    request.curlCommand(doPrint: true)
                }
            })
            .tryMap { result -> CommonNetworking.Response<T> in

                if logger.logOperationTime {
                    Common.CronometerManager.timeElapsed(cronometerId, print: true)
                }

                let statusCode = (result.response as? HTTPURLResponse)?.statusCode ?? -1
                let httpStatusCode = CommonNetworking.HTTPStatusCode(rawValue: statusCode) ?? .unknown

                if logger.dumpResponse {
                    let number = logger.number > 0 ? " #\(logger.number)" : ""
                    let prefix = logger.prefix.isEmpty ? "" : "\(logger.prefix): "
                    let status = "Status: \(statusCode), \(httpStatusCode)"
                    let responseDebug = String(decoding: result.data, as: UTF8.self)
                    let logMessage = "# ⤵️ Response\(number) ⤵️ \(status) | \(prefix) [\(requestDebug)]\n# \(responseDebug)"
                    Common_Logs.debug(logMessage)
                }

                //
                // General fail
                //
                guard httpStatusCode.isSuccess else {
                    throw CommonNetworking.APIError.finishWithStatusCodeAndJSONData(
                        code: statusCode,
                        description: "",
                        data: result.data,
                        jsonString: result.data.jsonString)
                }

                //
                // DELETE METHOD, with empty data on response
                //
                if result.data.isEmpty, let httpMethod = request.httpMethod,
                   httpMethod.lowercased() == CommonNetworking.HttpMethod.delete.rawValue.lowercased() {
                    throw CommonNetworking.APIError.finishWithStatusCodeAndJSONData(
                        code: statusCode,
                        description: "",
                        data: result.data,
                        jsonString: result.data.jsonString)
                }

                //
                // POST / GET METHOD
                //
                do {
                    let modelDto: T = try Self.decode(
                        result.data,
                        decoder,
                        responseFormat,
                        printError: true)
                    return CommonNetworking.Response(modelDto: modelDto, response: result.response)
                } catch {
                    // We can receive data/json that fails to map with T.
                    // Instead of fail hard, we return that
                    let httpStatusCode = CommonNetworking.HTTPStatusCode(rawValue: statusCode) ?? .none
                    let description = """
                    Status: \(statusCode), \(String(describing: httpStatusCode))
                    Fail coding to [\(T.self)] with received JSON
                    Error: \(error.localizedDescription)
                    """
                    throw CommonNetworking.APIError.finishWithStatusCodeAndJSONData(
                        code: statusCode,
                        description: description,
                        data: result.data,
                        jsonString: result.data.jsonString)
                }
            }
            .mapError { error in
                if let error = error as? CommonNetworking.APIError {
                    error
                } else {
                    CommonNetworking.APIError.network(description: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }

    func runAsync<T: Decodable>(
        _ request: URLRequest,
        _ decoder: JSONDecoder,
        _ logger: CommonNetworking.NetworkLogger,
        _ responseFormat: CommonNetworking.ResponseFormat,
        _ onCompleted:@escaping ()->())async throws -> T {
        let apiCall: AnyPublisher<
            T,
            CommonNetworking.APIError
        > = run(
            request,
            decoder,
            logger,
            responseFormat).flatMap { response in
            Just(response.modelDto).setFailureType(to: CommonNetworking.APIError.self).eraseToAnyPublisher()
            }.runBlockAndContinue { response in
                onCompleted() // Do something before returns
            }.eraseToAnyPublisher()
        return try await apiCall.async()
    }
}

//
// MARK: Private shared code
//

fileprivate extension CommonNetworking.NetworkAgent {
    func debugStringWith(_ requestDebugDump: String, _ error: Error) -> String {
        let result = """
        # Request failed
        # \(requestDebugDump)
        # [\(error.localizedDescription)]
        # [\(error)]
        """
        return result
    }

    static func extractFieldMaybe(field: String, data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
            if let value = json[field] {
                return "\(value)"
            }
            if let value = json[field.capitalised] {
                return "\(value)"
            }
            if let value = json[field.uppercased()] {
                return "\(value)"
            }
            if let value = json[field.lowercased()] {
                return "\(value)"
            }
        }
        return nil
    }

    static func decode<T: Decodable>(
        _ data: Data?,
        _ decoder: JSONDecoder,
        _ responseFormat: CommonNetworking.ResponseFormat,
        printError: Bool) throws -> T {
        switch responseFormat {
        case .json:
            return try decoder.decodeFriendly(T.self, from: data ?? Data(), printError: printError)
        case .csv:
            let data = try CommonNetworking.Utils.parseCSV(data: data ?? Data())
            return try decoder.decodeFriendly(T.self, from: data)
        }
    }
}
