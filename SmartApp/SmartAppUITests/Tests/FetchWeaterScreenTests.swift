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

final class FetchWeatherScreenTests: BaseUITests {
    let performanceTestsEnabled = false
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

    func testA1_appStartsAndUpdatesNavigationBarTitle() {
        appLaunch(launchArguments: [
            .shouldResetAllPreferences,
            .isAuthenticated
        ])
        tap(
            tabBarIndex: Constants.tabBarWeather,
            andWaitForStaticText: Constants.tab1Title,
            on: app
        )
    }

    func testA2_appStartsAndDisplayRecords() {
        testA1_appStartsAndUpdatesNavigationBarTitle() // Re-use test A1
        tap(
            staticText: Constants.tab1ListItem1,
            on: app
        )
        waitFor(staticText: Constants.tab1DetailsValue, on: app)
        XCTAssert(true)
    }
}

//
// MARK: Performance
//
extension FetchWeatherScreenTests {
    func testA1_performance() {
        guard performanceTestsEnabled else {
            XCTAssert(true)
            return
        }
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]
        // CPU Time (id): 1.642 s
        // Memory Peak Physical (id): 42440.922 kB
        // Memory Physical (id): 42417.984 kB
        measure(metrics: metrics) {
            testA1_appStartsAndUpdatesNavigationBarTitle()
        }
    }

    func testA2_performance() {
        guard performanceTestsEnabled else {
            XCTAssert(true)
            return
        }
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]
        // CPU Time (id): 1.922 s
        // Memory Peak Physical (id): 45295.027 kB
        // Memory Physical (id): 44747.802 kB
        measure(metrics: metrics) {
            testA2_appStartsAndDisplayRecords()
        }
    }
}
