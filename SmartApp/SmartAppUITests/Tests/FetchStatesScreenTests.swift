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
            .shouldResetAllPreferences,
            .isAuthenticated
        ])
        tap(
            tabBarIndex: Constants.tabBarUSAStats,
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
        tap(
            button: Accessibility.backButton.identifier,
            andWaitForStaticText: Constants.tab2ListItem,
            on: app
        )
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
        // CPU Time (id): 2.175 s
        // Memory Peak Physical (id): 52340.147 kB
        // Memory Physical (id): 51016.320 kB
        measure(metrics: metrics) {
            testA1_appStartsAndRouteToStates()
        }
    }

    func testA2_performance() {
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]
        // CPU Time (id): 2.415 s
        // Memory Peak Physical (id): 52985.715 kB
        // Memory Physical (id): 51042.586 kB
        measure(metrics: metrics) {
            testA2_appStartsAndRouteToStatesAndRouteBack()
        }
    }

    func testA2_scroll1xPerformance() {
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]

        // CPU Time (id): 2.688 s
        // Memory Peak Physical (id): 52245.133 kB
        // Memory Physical (id): 52022.310 kB
        measure(metrics: metrics) {
            testA1_appStartsAndRouteToStates()
            swipe(
                scrollView: Accessibility.scrollView.identifier,
                swipeUp: true,
                velocity: .fast,
                on: app
            )
        }
    }

    func testA2_scroll5xPerformance() {
        let metrics: [XCTMetric] = [
            XCTCPUMetric(application: app),
            XCTMemoryMetric(application: app)
        ]

        // CPU Time (id): 5.182 s
        // Memory Peak Physical (id): 52966.042 kB
        // Memory Physical (id): 52936.550 kB
        measure(metrics: metrics) {
            testA1_appStartsAndRouteToStates()
            for _ in 1...5 {
                swipe(
                    scrollView: Accessibility.scrollView.identifier,
                    swipeUp: true,
                    velocity: .fast,
                    on: app
                )
            }
        }
    }
}
