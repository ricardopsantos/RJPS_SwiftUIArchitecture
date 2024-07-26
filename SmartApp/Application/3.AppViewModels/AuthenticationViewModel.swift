//
//  AuthenticationManager.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Common
import Core

@MainActor
class AuthenticationViewModel: ObservableObject {
    // MARK: - Dependency Attributes
    private var secureAppPreferences: SecureAppPreferencesProtocol
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    private var userRepository: UserRepositoryProtocol

    // MARK: - Usage Attributes
    @Published var isAuthenticated = false {
        didSet {
            nonSecureAppPreferences.isAuthenticated = isAuthenticated
        }
    }

    // MARK: - Constructor

    init(
        secureAppPreferences: SecureAppPreferencesProtocol,
        nonSecureAppPreferences: NonSecureAppPreferencesProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.secureAppPreferences = secureAppPreferences
        self.nonSecureAppPreferences = nonSecureAppPreferences
        self.userRepository = userRepository
        self.isAuthenticated = nonSecureAppPreferences.isAuthenticated
    }

    public enum AuthenticationError: Swift.Error {
        case invalidPassword
    }

    // MARK: - Functions

    func login(user: Model.User) async throws {
        let authToken = "dummy_token_qwertyuiopasdfghjklzxcvbnm"
        guard user.password == "123" else {
            throw AuthenticationError.invalidPassword
        }
        userRepository.saveUser(user: Model.User(email: user.email, password: user.password))
        secureAppPreferences.password = user.password
        isAuthenticated = true
        AnalyticsManager.shared.handleCustomEvent(eventType: .login, properties: ["email": user.email])
    }

    func logout() async throws {
        // UserPreferences.shared.isAuthenticated = false
        isAuthenticated = false
    }

    func deleteAccount() async throws {
        isAuthenticated = false
        nonSecureAppPreferences.deleteAll()
        secureAppPreferences.deleteAll()
    }
}

// MARK: - Previews

extension AuthenticationViewModel {
    static var defaultForPreviews: AuthenticationViewModel {
        let configuration = ConfigurationViewModel.defaultForPreviews
        return .init(
            secureAppPreferences: configuration.secureAppPreferences,
            nonSecureAppPreferences: configuration.nonSecureAppPreferences,
            userRepository: configuration.userRepository
        )
    }
}
