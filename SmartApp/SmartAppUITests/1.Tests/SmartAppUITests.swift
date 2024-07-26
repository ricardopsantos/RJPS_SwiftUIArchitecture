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
        app.launchArguments = launchArguments
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

    func auxiliar_performLogin() {
        appLaunch(launchArguments: [
            "shouldDisableAnimations",
            "shouldResetAllPreferences",
            "onUITesting"
        ])
        exists(staticText: "Welcome", on: app)
        tap(
            textFieldIndex: 0,
            andType: "www.meumail@gmail.com",
            dismissKeyboard: false,
            on: app,
            delayBeforeTap: 1,
            delayBeforeType: 1
        )
        tap(
            textFieldIndex: 1,
            andType: "123",
            dismissKeyboard: false,
            on: app,
            delayBeforeTap: 1,
            delayBeforeType: 1
        )
    }

    //
    // MARK: - Login/Logout
    //

    func test_firstScreen() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            "shouldDisableAnimations",
            "shouldResetAllPreferences"
        ])
        waitFor(staticText: "Welcome", on: app)
    }

    func test_login() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        auxiliar_performLogin()
    }

    func test_logoutWithConfirm() {
        guard enabled else {
            XCTAssert(true)
            return
        }
        appLaunch(launchArguments: [
            "shouldDisableAnimations",
            "isAuthenticated"
        ])
 //       test_login()
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
    }
}
