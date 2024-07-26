//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
//
import Common
import Core

enum UITestingManager {
    static func setupForForTestingIfNeeded() {
        if CommandLine.arguments.contains("shouldDisableAnimations") {
            // clear your app state before running UI tests here.
            UIView.setAnimationsEnabled(false)
        }
        if CommandLine.arguments.contains("shouldResetAllPreferences") {
            DependenciesManager.Repository.nonSecureAppPreferences.deleteAll()
            DependenciesManager.Repository.secureAppPreferences.deleteAll()
            UserDefaults.resetStandardUserDefaults()
        }
        if CommandLine.arguments.contains("isAuthenticated") {
            NonSecureAppPreferences.shared.isAuthenticated = true
            NonSecureAppPreferences.shared.isOnboardingCompleted = true
            NonSecureAppPreferences.shared.isProfileComplete = true
        }
    }
}
