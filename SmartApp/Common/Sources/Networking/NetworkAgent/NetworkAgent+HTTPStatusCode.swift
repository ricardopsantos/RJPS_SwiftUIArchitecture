//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import Security
import CommonCrypto

//
// MARK: - HTTPStatusCode
//

public extension CommonNetworking {
    enum HTTPStatusCode: Int {
        case unknow = -1

        // Informational
        case continueRequest = 100
        case switchingProtocols = 101
        case processing = 102

        // Success
        case ok = 200
        case created = 201
        case accepted = 202
        case nonAuthoritativeInformation = 203
        case noContent = 204
        case resetContent = 205
        case partialContent = 206
        case multiStatus = 207
        case alreadyReported = 208
        case IMUsed = 226

        // Redirection
        case multipleChoices = 300
        case movedPermanently = 301
        case found = 302
        case seeOther = 303
        case notModified = 304
        case useProxy = 305
        case temporaryRedirect = 307
        case permanentRedirect = 308

        // Client Error
        case badRequest = 400
        case unauthorized = 401
        case paymentRequired = 402
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case notAcceptable = 406
        case proxyAuthenticationRequired = 407
        case requestTimeout = 408
        case conflict = 409
        case gone = 410
        case lengthRequired = 411
        case preconditionFailed = 412
        case payloadTooLarge = 413
        case URITooLong = 414
        case unsupportedMediaType = 415
        case rangeNotSatisfiable = 416
        case expectationFailed = 417
        case imATeapot = 418
        case misdirectedRequest = 421
        case unprocessableEntity = 422
        case locked = 423
        case failedDependency = 424
        case tooEarly = 425
        case upgradeRequired = 426
        case preconditionRequired = 428
        case tooManyRequests = 429
        case requestHeaderFieldsTooLarge = 431
        case unavailableForLegalReasons = 451

        // Server Error
        case internalServerError = 500
        case notImplemented = 501
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
        case HTTPVersionNotSupported = 505
        case variantAlsoNegotiates = 506
        case insufficientStorage = 507
        case loopDetected = 508
        case notExtended = 510
        case networkAuthenticationRequired = 511

        var isSuccess: Bool {
            (200...299).contains(rawValue)
        }
    }
}
