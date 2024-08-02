//
//  CoreProtocolsResolved.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
//
import Domain
import Core
import Common

public class DependenciesManager {
    private init() {}
    enum Services {
        public static var userService: UserServiceProtocol { UserService.shared }
        public static var weatherService: WeatherServiceProtocol { WeatherService.shared }
        public static var sampleService: SampleServiceProtocol { SampleService.shared }
        public static var dataUSAService: DataUSAServiceProtocol { DataUSAService.shared }
    }

    public enum Repository {
        public static var secureAppPreferences: SecureAppPreferencesProtocol { SecureAppPreferences.shared }
        public static var nonSecureAppPreferences: NonSecureAppPreferencesProtocol { NonSecureAppPreferences.shared }
        public static var userRepository: UserRepositoryProtocol { UserRepository(
            secureAppPreferences: secureAppPreferences,
            nonSecureAppPreferences: nonSecureAppPreferences
        ) }
    }
}
