//
//  LaunchApp.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Domain
import Common
import DesignSystem

// @main
struct SmartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let configuration: ConfigurationViewModel
    let appState: AppStateViewModel
    init() {
        SetupManager.shared.setup()
        let userService = DependenciesManager.Services.userService
        let sampleService = DependenciesManager.Services.sampleService
        let userRepository = DependenciesManager.Repository.userRepository
        let nonSecureAppPreferences = DependenciesManager.Repository.nonSecureAppPreferences
        let secureAppPreferences = DependenciesManager.Repository.secureAppPreferences
        let config: ConfigurationViewModel!

        let onTesting = UITestingManager.Options.onUITesting.enabled || Common_Utils.onUnitTests
        if onTesting {
            config = .init(
                userService: userService,
                weatherService: DependenciesManager.Services.weatherServiceMock,
                sampleService: sampleService,
                dataUSAService: DependenciesManager.Services.dataUSAServiceMock,
                userRepository: userRepository,
                nonSecureAppPreferences: nonSecureAppPreferences,
                secureAppPreferences: secureAppPreferences
            )
            self.configuration = config
        } else {
            config = .init(
                userService: userService,
                weatherService: DependenciesManager.Services.weatherService,
                sampleService: sampleService,
                dataUSAService: DependenciesManager.Services.dataUSAService,
                userRepository: userRepository,
                nonSecureAppPreferences: nonSecureAppPreferences,
                secureAppPreferences: secureAppPreferences
            )
            self.configuration = config
        }
        self.appState = .init()
        /*
         let appearance = UINavigationBarAppearance()
         appearance.titleTextAttributes = [.foregroundColor: Header.defaultColor]
         appearance.largeTitleTextAttributes = [.foregroundColor: Header.defaultColor]
         UINavigationBar.appearance().standardAppearance = appearance
         UINavigationBar.appearance().scrollEdgeAppearance = appearance*/
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator()
                .onAppear(perform: {
                    InterfaceStyleManager.setup(nonSecureAppPreferences: configuration.nonSecureAppPreferences)
                })
                .environmentObject(appState)
                .environmentObject(configuration)
        }
    }
}
