//
//  Configuration.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Foundation
//
import Domain
import Core

// ConfigurationViewModel is `ObservableObject` so that we can inject it on the view hierarchy
@MainActor
class ConfigurationViewModel: ObservableObject {
    // MARK: - Dependency Attributes

    // Services
    let userService: UserServiceProtocol
    let sampleService: SampleServiceProtocol
    let dataUSAService: DataUSAServiceProtocol

    // Repositories
    let dataBaseRepository: DataBaseRepositoryProtocol
    let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    let secureAppPreferences: SecureAppPreferencesProtocol
    let userRepository: UserRepositoryProtocol

    // ViewModels
    let authenticationViewModel: AuthenticationViewModel

    // MARK: - Usage/Auxiliar Attributes
    // private var cancelBag: CancelBag = .init()

    // MARK: - Constructor
    init(
        userService: UserServiceProtocol,
        sampleService: SampleServiceProtocol,
        dataUSAService: DataUSAServiceProtocol,
        dataBaseRepository: DataBaseRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        nonSecureAppPreferences: NonSecureAppPreferencesProtocol,
        secureAppPreferences: SecureAppPreferencesProtocol
    ) {
        self.userService = userService
        self.sampleService = sampleService
        self.dataUSAService = dataUSAService
        self.dataBaseRepository = dataBaseRepository
        self.userRepository = userRepository
        self.nonSecureAppPreferences = nonSecureAppPreferences
        self.secureAppPreferences = secureAppPreferences
        self.authenticationViewModel = AuthenticationViewModel(
            secureAppPreferences: secureAppPreferences,
            nonSecureAppPreferences: nonSecureAppPreferences,
            userRepository: userRepository
        )
    }
}

// MARK: - Previews

extension ConfigurationViewModel {
    static var defaultForPreviews: ConfigurationViewModel {
        ConfigurationViewModel(
            userService: DependenciesManager.Services.userService,
            sampleService: DependenciesManager.Services.sampleService,
            dataUSAService: DependenciesManager.Services.dataUSAService,
            dataBaseRepository: DependenciesManager.Repository.dataBaseRepository,
            userRepository: DependenciesManager.Repository.userRepository,
            nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
            secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
        )
    }
}
