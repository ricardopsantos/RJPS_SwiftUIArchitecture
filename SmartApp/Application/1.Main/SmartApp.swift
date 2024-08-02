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
            dataUSAService: DependenciesManager.Services.dataUSAService
        )
        SetupManager.shared.setup()
        self.configuration = config
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator()
                .environmentObject(configuration)
        }
    }
}
