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
}

//
// MARK: - Utils
//
extension LoginAndSessionTests {
    // Will fill user email and password.
    // User needs to be unauthenticated
    func auxiliar_performLogin() {
        exists(staticText: "Welcome", on: app)
        tap(
            textField: "txtEmail",
            andType: "mail@gmail.com",
            dismissKeyboard: false,
            on: app,
            delayBeforeTap: 0,
            delayBeforeType: 0
        )
        tap(
            secureTextField: "txtPassword",
            andType: "123",
            dismissKeyboard: false,
            on: app,
            delayBeforeTap: 0,
            delayBeforeType: 0
        )
        tap(button: "loginButton", andWaitForStaticText: "UserDetails", on: app)
    }

    // Will perform the onboarding flow.
    // User needs to authenticated, and on the correct flow
    func auxiliar_performOnBoarding() {
        //
        // User details screen
        //
        exists(staticText: "UserDetails", on: app)
        tap(
            textField: "txtName",
            andType: "Testing Joe",
            dismissKeyboard: false,
            on: app,
            delayBeforeTap: 0,
            delayBeforeType: 0
        )
        tap(button: "fwdButton", andWaitForStaticText: "Terms & Conditions", on: app)
        //
        // Terms and Conditions screen
        //
        tap(button: "readTermsAndConditions", on: app)
        tap(button: "fwdButton", andWaitForStaticText: "Onboarding", on: app)

        //
        // Onboarding screen
        //
        tap(button: "fwdButton", on: app) // Second
        tap(button: "fwdButton", andWaitForStaticText: "Europe/Lisbon", on: app) // Third
    }
}
