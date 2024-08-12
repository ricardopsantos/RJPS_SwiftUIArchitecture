//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension CommonNetworking {
    struct NetworkAgentRequest {
        public let path: String
        public let queryItems: [URLQueryItem]?
        public let httpMethod: CommonNetworking.HttpMethod
        public let httpBody: [String: Any]?
        public let headerValues: [String: String]?
        public let serverURL: String // baseURLString
        public let responseFormat: CommonNetworking.ResponseFormat

        public init(
            path: String,
            queryItems: [URLQueryItem]?,
            httpMethod: CommonNetworking.HttpMethod,
            httpBody: [String: Any]?,
            headerValues: [String: String]?,
            serverURL: String,
            responseType: CommonNetworking.ResponseFormat
        ) {
            self.path = path
            self.httpMethod = httpMethod
            self.httpBody = httpBody
            self.headerValues = headerValues
            self.queryItems = queryItems
            self.serverURL = serverURL
            self.responseFormat = responseType
        }

        public var urlRequest: URLRequest? {
            let serverURLEscaped = serverURL.dropLastIf("/")
            var pathEscaped = path.dropFirstIf("/")
            if let escaped = pathEscaped.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               pathEscaped != escaped {
                pathEscaped = escaped
            }

            var query: String = ""
            if let queryItems {
                var components = URLComponents()
                components.queryItems = queryItems
                query = components.url?.absoluteString ?? ""
            }

            let urlString: String = pathEscaped.isEmpty ? serverURLEscaped : serverURLEscaped + "/" + pathEscaped + query

            let urlRequest = URLRequest.with(
                urlString: urlString.trim,
                httpMethod: httpMethod.rawValue,
                httpBody: httpBody,
                headerValues: headerValues
            )
            return urlRequest
        }

        public var curlCommand: String? {
            urlRequest?.curlCommand(doPrint: false)
        }

        public var httpBodyAsJSON: Any? {
            guard let httpBody = urlRequest?.httpBody else { return nil }
            let json = try? JSONSerialization.jsonObject(with: httpBody, options: [])
            if let jsonDictionary = json as? [String: Any] {
                return jsonDictionary
            } else if let jsonArray = json as? [Any] {
                return jsonArray
            } else {
                return nil
            }
        }
    }
}
