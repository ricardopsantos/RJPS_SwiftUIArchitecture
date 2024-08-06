//
//  AppErrors.swift
//  SmartApp
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
import Domain

// swiftlint:disable switch_case_alignment
public extension AppErrors {
    /// Hide business logic from being displayed to the user
    var localizedForUser: String {
        let defaultMessage = "PleaseTryAgainLatter".localized
        return switch self {
        case .ok: ""
        case .cacheNotFound: defaultMessage
        case .notFound: defaultMessage
        case .genericError
             : defaultMessage
        case .noInternet: "NotInternetPleaseTryAgainLatter".localized
        case .serverErrorMessage: defaultMessage

        // User errors
        case .invalidPassword: "Invalid user or password".localizedMissing
            
        // WebAPI
        case .network: defaultMessage
        case .parsing: defaultMessage
        case .finishWithStatusCodeAndJSONData: defaultMessage

        // Bussines
        case .userIsNotAuthenticated: defaultMessage
        case .tokenStoringFailed: defaultMessage

        }
    }
}

// swiftlint:enable switch_case_alignment
