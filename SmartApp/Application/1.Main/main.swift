//
//  main.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Foundation
import UIKit
import SwiftUI

struct EmptyApp: App {
    var body: some Scene {
        WindowGroup {}
    }
}

if NSClassFromString("XCTestCase") != nil { // Unit Testing
    EmptyApp.main()
} else { // App
    SmartApp.main()
}
