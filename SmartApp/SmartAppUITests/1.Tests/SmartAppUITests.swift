//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import XCTest
import Nimble
//
import Common

@testable import Smart_Dev

final class SmartAppUITests: XCTestCase {
    var enabled: Bool = true
    lazy var app: XCUIApplication = {
        let app = XCUIApplication()
        return app
    }()

    func appLaunch(launchArguments: [String]) {
        app.launchArguments = launchArguments + ["shouldDisableAnimations"]
        app.launch()
    }

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
    // MARK: - Login/Logout
    //

    func test_welcomeScreen() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            "shouldResetAllPreferences"
        ])
        waitFor(staticText: "Welcome", on: app)
    }

    func test_login() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            "shouldResetAllPreferences"
        ])
        auxiliar_performLogin()
    }

    func test_onBoarding() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            "shouldResetAllPreferences"
        ])
        auxiliar_performLogin()
        auxiliar_performOnBoarding()
    }
    /*
    func test_logoutWithConfirm() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            "isAuthenticated"
        ])
        tap(
            button: "AccessibilityIdentifier.toolBarBtn1WithMeaningfulName.value",
            on: app
        )
        tap(
            button: "Logout",
            on: app
        )
        tap(
            alert: "Welcome",
            option: "Yes",
            andWaitForStaticText: "loginScreenMessage",
            on: app
        )
    }*/
}

//
// MARK: - Utils flows
//
extension SmartAppUITests {
    
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
            on: app
        )
        tap(button: "loginButton", on: app)
    }

    // Will perform the onboarding flow.
    // User needs to authenticated, and on the correct flow
    func auxiliar_performOnBoarding() {
        //
        // User details screen
        //
        //exists(staticText: "UserDetails", on: app)
        tap(
            textField: "txtName",
            andType: "Testing Joe",
            dismissKeyboard: false,
            on: app,
            delayBeforeTap: 1,
            delayBeforeType: 0
        )
        tap(button: "fwdButton", on: app)
        //
        // Terms and Conditions screen
        //
        exists(staticText: "Terms & Conditions", on: app)
        tap(button: "readTermsAndConditions", on: app)
        tap(button: "fwdButton", on: app)

        //
        // Onboarding screen
        //
        exists(staticText: "Onboarding", on: app) // First
        tap(button: "fwdButton", on: app) // Second
        tap(button: "fwdButton", on: app) // Third
        waitFor(staticText: "Europe/Lisbon", on: app) // App main screen
        
    }
}
