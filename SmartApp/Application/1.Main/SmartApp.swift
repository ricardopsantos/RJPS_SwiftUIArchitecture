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
    let appState: AppStateViewModel
    init() {
        let config: ConfigurationViewModel = .init(
            userService: DependenciesManager.Services.userService,
            weatherService: DependenciesManager.Services.weatherService,
            sampleService: DependenciesManager.Services.sampleService,
            dataUSAService: DependenciesManager.Services.dataUSAService,
            userRepository: DependenciesManager.Repository.userRepository,
            nonSecureAppPreferences: DependenciesManager.Repository.nonSecureAppPreferences,
            secureAppPreferences: DependenciesManager.Repository.secureAppPreferences
        )
        SetupManager.shared.setup(nonSecureAppPreferences: config.nonSecureAppPreferences)
        self.configuration = config
        self.appState = .init()
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator()
                .environmentObject(appState)
                .environmentObject(configuration)
        }
    }
}
