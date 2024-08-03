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

final class LoginAndSessionTests: BaseUITests {
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

    //
    // MARK: - testAxxx : Splash Screen
    //

    func testA1_welcomeScreen() {
        appLaunch(launchArguments: [
            "shouldResetAllPreferences"
        ])
        waitFor(staticText: "Welcome", on: app)
    }

    //
    // MARK: - testBxxx :Login
    //

    func testB1_login() {
        appLaunch(launchArguments: [
            "shouldResetAllPreferences"
        ])
        auxiliar_performLogin()
    }

    func testB2_onBoarding() {
        appLaunch(launchArguments: [
            "shouldResetAllPreferences"
        ])
        auxiliar_performLogin()
        auxiliar_performOnBoarding()
    }

    //
    // MARK: - testBxxx :Logout
    //

    func testC1_logoutCancel() {
        appLaunch(launchArguments: [
            "isAuthenticated"
        ])
        tap(
            tabBarIndex: 2,
            andWaitForStaticText: "Settings",
            on: app
        )
        tap(
            button: "Logout",
            andWaitForStaticText: "LogoutBottomSheetTitle",
            on: app
        )
        tap(
            button: "No",
            andWaitForStaticText: "Settings",
            on: app
        )
    }

    func testC2_logoutConfirm() {
        appLaunch(launchArguments: [
            "isAuthenticated"
        ])
        tap(
            tabBarIndex: 2,
            andWaitForStaticText: "Settings",
            on: app
        )
        tap(
            button: "Logout",
            andWaitForStaticText: "LogoutBottomSheetTitle",
            on: app
        )
        tap(
            button: "Yes",
            andWaitForStaticText: "Welcome",
            on: app
        )
    }

    //
    // MARK: - testCxxx : Delete Account
    //

    func testC1_deleteAccountCancel() {
        appLaunch(launchArguments: [
            "isAuthenticated"
        ])
        tap(
            tabBarIndex: 3,
            andWaitForStaticText: "Settings",
            on: app
        )
        tap(
            button: "DeleteAccount",
            andWaitForStaticText: "DeleteAccountBottomSheetTitle",
            on: app
        )
        tap(
            button: "No",
            andWaitForStaticText: "Settings",
            on: app
        )
    }

    func testC2_deleteAccountConfirm() {
        appLaunch(launchArguments: [
            "isAuthenticated"
        ])
        tap(
            tabBarIndex: 3,
            andWaitForStaticText: "Settings",
            on: app
        )
        tap(
            button: "DeleteAccount",
            andWaitForStaticText: "DeleteAccountBottomSheetTitle",
            on: app
        )
        tap(
            button: "Yes",
            andWaitForStaticText: "Welcome",
            on: app
        )
    }
}
