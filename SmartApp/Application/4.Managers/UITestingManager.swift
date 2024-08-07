//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
//
import Common
import Core

public extension UITestingManager {
    enum Options: String {
        case onUITesting
        case shouldDisableAnimations
        case shouldResetAllPreferences
        case isAuthenticated
        
        var enabled: Bool {
            switch self {
            case .onUITesting:
                return UITestingManager.enabled(option: self)
            default:
                guard UITestingManager.enabled(option: .onUITesting) else {
                    return false
                }
                return UITestingManager.enabled(option: self)
            }
        }
    }
}

public enum UITestingManager {
    private static func enabled(option: UITestingManager.Options) -> Bool {
        CommandLine.arguments.contains(option.rawValue)
    }
    
    public static func setup() {
        
        guard enabled(option: .onUITesting) else {
            return
        }
        
        if enabled(option: .shouldDisableAnimations) {
            UIView.setAnimationsEnabled(false)
        }
        
        if enabled(option: .shouldResetAllPreferences) {
            DependenciesManager.Repository.nonSecureAppPreferences.deleteAll()
            DependenciesManager.Repository.secureAppPreferences.deleteAll()
            UserDefaults.resetStandardUserDefaults()
        }
        
        if enabled(option: .isAuthenticated) {
            var nonSecureAppPreferences = DependenciesManager.Repository.nonSecureAppPreferences
            nonSecureAppPreferences.isAuthenticated = true
            nonSecureAppPreferences.isAuthenticated = true
            nonSecureAppPreferences.isProfileComplete = true
            nonSecureAppPreferences.isPrivacyPolicyAccepted = true
            nonSecureAppPreferences.isOnboardingCompleted = true
        }
    }
}
