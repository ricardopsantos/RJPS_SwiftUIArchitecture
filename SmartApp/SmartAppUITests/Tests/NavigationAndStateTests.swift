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

final class NavigationAndStateTests: BaseUITests {
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
            tabBarIndex: 0,
            andWaitForStaticText: Constants.tab1Title,
            on: app
        )
    }

    func testA2_counterStateIsNotLostOnNavigation() {
        testA1_appStartsAndUpdatesNavigationBarTitle() // Re-use test A1

        // Increment Counter...
        tap(button: "Increment", andWaitForStaticText: "Counter: 1", on: app)
        tap(button: "Increment", andWaitForStaticText: "Counter: 2", on: app)

        // Push details and go back...
        tap(staticText: Constants.tab1ListItem, andWaitForStaticText: Constants.tab1DetailsTitle, on: app)
        tap(button: "backButton", andWaitForStaticText: Constants.tab1Title, on: app)

        // Increment counter and push details again
        tap(button: "Increment", andWaitForStaticText: "Counter: 3", on: app)
        tap(staticText: Constants.tab1ListItem, andWaitForStaticText: Constants.tab1DetailsTitle, on: app)

        // Change to usa stats tab
        tap(
            tabBarIndex: 1,
            andWaitForStaticText: Constants.tab2Title,
            on: app
        )

        // Go back to original tab
        tap(
            tabBarIndex: 0,
            andWaitForStaticText: Constants.tab1DetailsTitle,
            on: app
        )
        // Dismiss details
        tap(button: "backButton", andWaitForStaticText: Constants.tab1Title, on: app)

        // Check state
        exists(staticText: "Counter: 3", on: app)

        // Increment counter and push details again
        tap(button: "Increment", andWaitForStaticText: "Counter: 4", on: app)
        tap(staticText: Constants.tab1ListItem, andWaitForStaticText: Constants.tab1DetailsTitle, on: app)

        // Change tab and push details for Tab 2
        tap(
            tabBarIndex: 1,
            andWaitForStaticText: Constants.tab2Title,
            on: app
        )
        tap(staticText: Constants.tab2ListItem, on: app) // Tapped list item
        waitFor(staticText: Constants.tab2DetailsTitle, on: app)

        // Go back to original tab
        tap(
            tabBarIndex: 0,
            andWaitForStaticText: Constants.tab1DetailsTitle,
            on: app
        )

        tap(
            tabBarIndex: 1,
            andWaitForStaticText: Constants.tab2DetailsTitle,
            on: app
        )
        waitFor(staticText: Constants.tab2DetailsTitle, on: app)
        tap(button: "backButton", andWaitForStaticText: Constants.tab2Title, on: app)
    }
}