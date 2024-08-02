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

    func testA1_appStartsAndUpdatesTitle() {
        appLaunch(launchArguments: [
            "shouldResetAllPreferences"
        ])
        waitFor(staticText: "Nation 10", on: app)
    }

    func testA1_appStartsAndDisplayRecords() {
        appLaunch(launchArguments: [
            "shouldResetAllPreferences"
        ])
        waitFor(staticText: "United States 2022", on: app)
        waitFor(staticText: "United States 2021", on: app)
        waitFor(staticText: "United States 2020", on: app)
    }

}
