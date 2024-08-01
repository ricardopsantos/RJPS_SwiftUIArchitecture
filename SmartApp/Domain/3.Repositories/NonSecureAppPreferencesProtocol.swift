//
//  NonSecureAppPreferencesProtocol.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
import Combine
//
import Common

public enum NonSecureAppPreferencesOutputActions: Equatable {
    case deletedAll
    case changedKey(key: NonSecureAppPreferencesKey)
}

public enum NonSecureAppPreferencesKey: String, CaseIterable, Equatable {
    case user
    case userName
    case userPIN
    case isAuthenticated
    case isProfileComplete
    case isPrivacyPolicyAccepted
    case isOnboardingCompleted
    case selectedAppearance
}

public protocol NonSecureAppPreferencesProtocol {
    // MARK: - Properties

    /// The `UserDefaults` instance used for storing non-secure preferences.
    var nonSecureUserDefaults: UserDefaults { get }

    /// A Boolean value indicating whether the user is authenticated.
    var isAuthenticated: Bool { get set }

    /// A Boolean value indicating whether the user profile is complete.
    var isProfileComplete: Bool { get set }

    /// A Boolean value indicating whether the user has accepted the privacy policy.
    var isPrivacyPolicyAccepted: Bool { get set }

    /// A Boolean value indicating whether the onboarding process is completed.
    var isOnboardingCompleted: Bool { get set }

    /// The selected appearance theme.
    var selectedAppearance: String? { get set }

    // MARK: - Utilities

    /// Emits actions related to non-secure app preferences, allowing listeners to react to changes.
    /// - Parameter filter: An array of actions to filter the output stream.
    /// - Returns: A publisher emitting non-secure app preferences actions.
    func output(_ filter: [NonSecureAppPreferencesOutputActions]) -> AnyPublisher<NonSecureAppPreferencesOutputActions, Never>

    // MARK: - Methods

    /// Deletes all non-secure app preferences.
    func deleteAll()
}
