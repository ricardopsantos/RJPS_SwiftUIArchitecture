//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
//
import Common
import Core

public enum UITestingManager {
    public enum Options: String {
        case shouldDisableAnimations
        case shouldResetAllPreferences
        case isAuthenticated

        public var rawValue: String {
            "\(self)"
        }
    }

    public static func setupForForTestingIfNeeded() {
        if CommandLine.arguments.contains(UITestingManager.Options.shouldDisableAnimations.rawValue) {
            // clear your app state before running UI tests here.
            UIView.setAnimationsEnabled(false)
        }
        if CommandLine.arguments.contains(UITestingManager.Options.shouldResetAllPreferences.rawValue) {
            UserDefaults.resetStandardUserDefaults()
        }
    }
}
