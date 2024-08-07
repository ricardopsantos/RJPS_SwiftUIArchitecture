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
            andWaitForStaticText: Constants.tab2Title,
            on: app
        )
        tap(staticText: Constants.tab2ListItem, on: app)
        waitFor(
            staticText: Constants.tab2DetailsTitle,
            on: app
        )
    }

    func testA2_appStartsAndRouteToStatesAndRouteBack() {
        testA1_appStartsAndRouteToStates() // Re-use testA1
        // After tap back button, should appear previous screen navigation title
        tap(button: "backButton", andWaitForStaticText: Constants.tab2ListItem, on: app)
    }
}

//
// MARK: Performance
//
extension FetchStatesScreenTests {
    func testA1_performance() {
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]
        // CPU Time (id): 2.446 s
        // Memory Peak Physical (id): 58431.757 kB
        // Memory Physical (id): 55286.029 kB
        measure(metrics: metrics) {
            testA1_appStartsAndRouteToStates()
        }
    }

    func testA2_performance() {
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]
        // CPU Time (id): 2.771 s
        // Memory Peak Physical (id): 59352.538 kB
        // Memory Physical (id): 57324.211 kB
        measure(metrics: metrics) {
            testA2_appStartsAndRouteToStatesAndRouteBack()
        }
    }
}
