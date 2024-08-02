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
        SetupManager.shared.setup()
        self.configuration = .init(
            dataUSAService: DependenciesManager.Services.dataUSAService
        )
    }

    var body: some Scene {
        WindowGroup {
            RootViewCoordinator()
                .environmentObject(configuration)
        }
    }
}
