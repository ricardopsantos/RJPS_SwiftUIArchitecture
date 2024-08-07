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

final class FetchNationScreenTests: BaseUITests {
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
            "shouldResetAllPreferences",
            "isAuthenticated"
        ])
        tap(
            tabBarIndex: 1,
            andWaitForStaticText: Constants.tab2Title,
            on: app
        )
    }

    func testA2_appStartsAndDisplayRecords() {
        testA1_appStartsAndUpdatesNavigationBarTitle() // Re-use test A1
        waitFor(
            staticText: Constants.tab2ListItem,
            on: app
        )
    }
}


//
// MARK: Performance
//
extension FetchNationScreenTests {
    
    func testA1_performance() {
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]
        // CPU Time (id): 1.805 s
        // Memory Physical (id): 53000.000 kB
        measure(metrics: metrics) {
            testA1_appStartsAndUpdatesNavigationBarTitle()
        }
    }
    
    func testA2_performance() {
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]
        // CPU Time (id): 1.939 s
        // Memory Physical (id): 53490.342 kB
        measure(metrics: metrics) {
            testA2_appStartsAndDisplayRecords()
        }
    }

}
