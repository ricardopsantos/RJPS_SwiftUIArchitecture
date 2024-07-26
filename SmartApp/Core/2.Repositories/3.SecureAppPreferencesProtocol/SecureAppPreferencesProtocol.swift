//
//  SecureAppPreferencesProtocol.swift
//  Core
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Combine
import Foundation

public protocol SecureAppPreferencesProtocol {
    
    // MARK: - Properties

    /// The authentication token used for secure operations.
    var authToken: String { get set }

    /// The user's password, stored securely.
    var password: String { get set }

    // MARK: - Utilities

    /// Emits actions related to secure app preferences, allowing listeners to react to changes.
    /// - Parameter filter: An array of actions to filter the output stream.
    /// - Returns: A publisher emitting secure app preferences actions.
    func output(_ filter: [SecureAppPreferencesOutputActions]) -> AnyPublisher<SecureAppPreferencesOutputActions, Never>

    // MARK: - Methods

    /// Deletes all secure app preferences.
    func deleteAll()
}
