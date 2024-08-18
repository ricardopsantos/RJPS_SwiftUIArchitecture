//
//  File.swift
//  SmartAppUnitTests
//
//  Created by Ricardo Santos on 07/08/2024.
//

import Foundation
import XCTest
import SwiftUI
@testable import Smart_Dev

class PreferenceKeyTests: XCTestCase {
    func testTotalWidthPreferenceKey() {
        let rootView = ParentView()
        let hostingController = UIHostingController(rootView: rootView)

        // Set up the environment for testing
        hostingController.view.frame = UIScreen.main.bounds
        let window = UIWindow()
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // Render the view hierarchy
        RunLoop.main.run(until: Date())

        // Check initial total width
        XCTAssert(rootView.totalWidth == 0)

        // Check updated total width
        RunLoop.main.run(until: Date())
        //   XCTAssertGreaterThan(rootView.totalWidth, 0)
    }
}
