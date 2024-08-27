//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
//
import Firebase
//
import Domain
import Common
import Core
import DevTools
import DesignSystem

public class SetupManager {
    private init() {}
    static let shared = SetupManager()
    func setup(dataBaseRepository: DataBaseRepositoryProtocol) {
        CPPWrapper.disable_gdb() // Security: Detach debugger for real device
        CPPWrapper.crash_if_debugged() // Security: Crash app if debugger Detach failed
        DevTools.Log.setup()
        
        if FirebaseApp.configIsValidAndAvailable {
            FirebaseApp.configure()
        } else {
            DevTools.Log.debug(.log("Firebase config not available or invalid"), .business)
        }
        
        UITestingManager.setup()
        FontsName.setup()
        if Common_Utils.onDebug, Common_Utils.false {
            UserDefaults.standard.set(true, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(1, forKey: "com.apple.CoreData.SQLDebug")
        } else {
            UserDefaults.standard.set(false, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(0, forKey: "com.apple.CoreData.SQLDebug")
        }
        dataBaseRepository.initDataBase()
    }
    

}

extension FirebaseApp {
    public static var configIsValidAndAvailable: Bool {
        let plistPath = "GoogleService-Info-" + Common.AppInfo.bundleIdentifier
        if let path = Bundle.main.path(forResource: plistPath, ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) {
                if let value = plist["API_KEY"] as? String, !value.isEmpty {
                    return true
                }
            }
        }
        return false
    }
}
