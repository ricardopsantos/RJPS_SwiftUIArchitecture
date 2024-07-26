//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
//
import Firebase
import Common
import Core
import DevTools

public class SetupManager {
    private init() {}
    static let shared = SetupManager()

    func setup(nonSecureAppPreferences: NonSecureAppPreferencesProtocol) {
        CPPWrapper.disable_gdb() // Security: Detach debugger for real device
        CPPWrapper.crash_if_debugged() // Security: Crash app if debugger Detach failed
        DevTools.Log.setup()
        FirebaseApp.configure()
        UITestingManager.setupForForTestingIfNeeded()
        InterfaceStyle.setupUserInterfaceStyle(nonSecureAppPreferences: nonSecureAppPreferences)
        if Common_Utils.onDebug {
            UserDefaults.standard.set(true, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(1, forKey: "com.apple.CoreData.SQLDebug")
        } else {
            UserDefaults.standard.set(false, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(0, forKey: "com.apple.CoreData.SQLDebug")
        }
    }
}