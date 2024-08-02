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

    func setup() {
        CPPWrapper.disable_gdb() // Security: Detach debugger for real device
        CPPWrapper.crash_if_debugged() // Security: Crash app if debugger Detach failed
        DevTools.Log.setup()
        FirebaseApp.configure()
        UITestingManager.setupForForTestingIfNeeded()
        FontsName.setup()
    }
}
