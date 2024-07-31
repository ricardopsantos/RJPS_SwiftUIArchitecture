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
    @Published var isAuthenticated = false

    // MARK: - Auxiliar Attributes
    private var cancelBag: CancelBag = .init()

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

        nonSecureAppPreferences.output([.changedKey(key: .isAuthenticated)])
            .sinkToReceiveValue { [weak self] _ in
                self?.isAuthenticated = nonSecureAppPreferences.isAuthenticated
            }.store(in: cancelBag)
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
        nonSecureAppPreferences.isAuthenticated = true
        // isAuthenticated = true
        AnalyticsManager.shared.handleCustomEvent(eventType: .login, properties: ["email": user.email])
    }

    func logout() async throws {
        nonSecureAppPreferences.isAuthenticated = false
        // isAuthenticated = false
    }

    func deleteAccount() async throws {
        nonSecureAppPreferences.isAuthenticated = false
        // isAuthenticated = false
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
