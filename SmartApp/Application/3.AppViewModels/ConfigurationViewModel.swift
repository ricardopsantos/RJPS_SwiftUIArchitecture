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
    let weatherService: WeatherServiceProtocol
    let sampleService: SampleServiceProtocol
    let dataUSAService: DataUSAServiceProtocol

    // Repositories
    let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    let secureAppPreferences: SecureAppPreferencesProtocol
    let userRepository: UserRepositoryProtocol

    // ViewModels
    let authenticationViewModel: AuthenticationViewModel

    // MARK: - Auxiliar Attributes
    // private var cancelBag: CancelBag = .init()

    // MARK: - Usage Attributes

    // MARK: - Constructor
    init(
        userService: UserServiceProtocol,
        weatherService: WeatherServiceProtocol,
        sampleService: SampleServiceProtocol,
        dataUSAService: DataUSAServiceProtocol,
        userRepository: UserRepositoryProtocol,
        nonSecureAppPreferences: NonSecureAppPreferencesProtocol,
        secureAppPreferences: SecureAppPreferencesProtocol
    ) {
        self.userService = userService
        self.weatherService = weatherService
        self.sampleService = sampleService
        self.dataUSAService = dataUSAService
        self.userRepository = userRepository
        self.nonSecureAppPreferences = nonSecureAppPreferences
        self.secureAppPreferences = secureAppPreferences
        self.authenticationViewModel = AuthenticationViewModel(
            secureAppPreferences: secureAppPreferences,
            nonSecureAppPreferences: nonSecureAppPreferences,
            userRepository: userRepository
        )
    }

    // MARK: - Functions
}

// MARK: - Previews

extension ConfigurationViewModel {
    static var defaultForPreviews: ConfigurationViewModel {
        ConfigurationViewModel(
            userService: DependenciesManager.Services.userService,
            weatherService: DependenciesManager.Services.weatherService,
            sampleService: DependenciesManager.Services.sampleService,
            dataUSAService: DependenciesManager.Services.dataUSAService,
            userRepository: DependenciesManager.Repository.userRepository,
            nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
            secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
        )
    }
}
