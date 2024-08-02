//
//  LaunchApp.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common

// @main
struct SmartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let configuration: ConfigurationViewModel
    init() {
        let config: ConfigurationViewModel = .init(
            userService: DependenciesManager.Services.userService,
            weatherService: DependenciesManager.Services.weatherService,
            sampleService: DependenciesManager.Services.sampleService,
            userRepository: DependenciesManager.Repository.userRepository, 
            dataUSAService: DependenciesManager.Services.dataUSAService,
            nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
            secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
        )
        SetupManager.shared.setup(nonSecureAppPreferences: config.nonSecureAppPreferences)
        self.configuration = config
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator()
                .environmentObject(configuration)
        }
    }
}
