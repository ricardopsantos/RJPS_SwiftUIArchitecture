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
            andWaitForStaticText: "USA Population: Last 10 years",
            on: app
        )
    }

    func testA2_appStartsAndDisplayRecords() {
        testA1_appStartsAndUpdatesNavigationBarTitle() // Re-use test A1
        waitFor(staticText: "Year: 2022", on: app)
        waitFor(staticText: "Year: 2021", on: app)
        waitFor(staticText: "Year: 2020", on: app)
    }
}
