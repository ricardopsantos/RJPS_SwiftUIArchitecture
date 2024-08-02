//
//  AppErrors.swift
//  SmartApp
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
import Domain

public extension AppErrors {
    /// Hide business logic from being displayed to the user
    var localizedForUser: String {
        let defaultMessage = "PleaseTryAgainLatter".localized
        // swiftlint:disable switch_case_alignment
        return switch self {
        case .ok: ""
        case .cacheNotFound: defaultMessage
        case .notFound: defaultMessage
        case .genericError
             : defaultMessage
        case .noInternet: "NotInternetPleaseTryAgainLatter".localized
        case .serverErrorMessage: defaultMessage

        // WebAPI
        case .network: defaultMessage
        case .parsing: defaultMessage
        case .finishWithStatusCodeAndJSONData: defaultMessage
        }
        // swiftlint:enable switch_case_alignment
    }
}
