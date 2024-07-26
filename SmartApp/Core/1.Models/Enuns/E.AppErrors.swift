//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Common

public enum AppErrors: Error, Equatable, Hashable, Codable {
    case ok // No error
    case cacheNotFound // No error
    case notFound // No error
    case genericError(devMessage: String)
    case noInternet
    case serverErrorMessage(message: String)

    case userIsNotAuthenticated
    case tokenStoringFailed

    // WebAPI
    case network(description: String)
    case parsing(description: String, data: Data?)
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

    public var isNotFoundHTTPStatusCode: Bool {
        isHTTPStatusCode(.notFound)
    }

    public var isNetworkError: Bool {
        switch self {
        case .network:
            return true
        default:
            return false
        }
    }
}

public extension CommonNetworking.APIError {
    var toAppError: AppErrors {
        switch self {
        case .ok:
            .ok
        case .genericError(devMessage: let devMessage):
            .genericError(devMessage: devMessage)
        case .finishWithStatusCodeAndJSONData(
            code: let code,
            description: let description,
            data: let data,
            jsonString: let jsonString
        ):
            .finishWithStatusCodeAndJSONData(
                code: code,
                description: description,
                data: data,
                jsonString: jsonString
            )
        case .parsing(description: let description, data: let data):
            .parsing(
                description: description,
                data: data
            )
        case .network(description: let description):
            .network(description: description)
        }
    }
}
