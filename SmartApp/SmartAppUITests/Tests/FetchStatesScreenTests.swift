//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

/*
 https://medium.com/@jpmtech/level-up-your-career-by-adding-ui-tests-to-your-swiftui-app-37cbffeba459
 */

@testable import Smart_Dev

import XCTest
import Combine
import Nimble
//
import Common

final class FetchStatesScreenTests: BaseUITests {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}
    
    func testA1_appStartsAndRouteToStates() {
        appLaunch(launchArguments: [
            "shouldResetAllPreferences",
            "isAuthenticated"
        ])
        tap(
            tabBarIndex: 1,
            andWaitForStaticText: "USA Population: Last 10 years",
            on: app
        )
        tap(staticText: "Year: 2022", on: app) // Tapped list item
        waitFor(staticText: "USA States Population for 2022", on: app) // Should appear the next screen navigation title
    }

    func testA2_appStartsAndRouteToStatesAndRouteBack() {
        testA1_appStartsAndRouteToStates() // Re-use testA1
        // After tap back button, should appear previous screen navigation title
        tap(button: "backButton", andWaitForStaticText: "Year: 2022", on: app)
    }
}
