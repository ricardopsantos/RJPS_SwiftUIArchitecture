//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension CommonNetworking {
    enum APIError: Error {
        case ok // no error

        case genericError(devMessage: String)
        case parsing(description: String, data: Data?)
        case network(description: String)
        case finishWithStatusCodeAndJSONData(
            code: Int,
            description: String?,
            data: Data?,
            jsonString: String?
        )

        // UTILS
        public func isHTTPStatusCode(_ httpStatusCode: CommonNetworking.HTTPStatusCode) -> Bool {
            switch self {
            case .finishWithStatusCodeAndJSONData(
                code: let code,
                description: _,
                data: _,
                jsonString: _
            ):
                return CommonNetworking.HTTPStatusCode(rawValue: code) == httpStatusCode
            default:
                return false
            }
        }

        public var isBadRequestHTTPStatusCode: Bool {
            isHTTPStatusCode(.badRequest)
        }

        public var isForbiddenHTTPStatusCode: Bool {
            isHTTPStatusCode(.forbidden)
        }

        public var isUnauthorizedHTTPStatusCode: Bool {
            isHTTPStatusCode(.unauthorized)
        }

        public var isNotFoundHTTPStatusCode: Bool {
            isHTTPStatusCode(.notFound)
        }

        public var isNetworkError: Bool {
            switch self {
            case .network:
                true
            default:
                false
            }
        }
    }
}
