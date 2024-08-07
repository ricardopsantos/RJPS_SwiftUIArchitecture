//
//  main.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Foundation
import UIKit
import SwiftUI

/// Speed up testing time.
/// Ref: https://samwize.com/2023/01/18/disconnect-your-app-from-unit-testing/#google_vignette

struct EmptyApp: App {
    var body: some Scene {
        WindowGroup {}
    }
}

if NSClassFromString("XCTestCase") != nil { // Unit Testing
    EmptyApp.main()
} else { // App
    print("fazer testes de carga (ui) para o ecran do tempo")
    SmartApp.main()
}
