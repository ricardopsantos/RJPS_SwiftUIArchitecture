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

let cancelBag = CancelBag()
var timeout: Int = 5
var loadedAny: Any?

enum Constants {
    static let tab1Title = "Current Weather"
    static let tab1DetailsTitle = "Weather Details"
    static let tab1DetailsValue = "32 °C"
    static let tab1ListItem = "Lisbon"
    //
    static let tab2Title = "USA Population: Last 45 years"
    static let tab2DetailsTitle = "USA States Population for 1980"
    static let tab2ListItem = "Year: 1980"
    //
    static let tab4Title = "Settings"
}

// COPY OF THE APPLICATION `Accessibility` enum
enum Accessibility: String, CaseIterable {
    // Text Fields
    case txtName
    case txtUserName
    case txtEmail
    case txtPassword

    // Buttons
    case loginButton
    case logoutButton
    case deleteButton
    case saveButton
    case fwdButton
    case backButton
    case confirmButton
    case cancelButton

    // CheckBox
    case readTermsAndConditions
    case scrollView

    // Not applied
    case undefined

    public var identifier: String {
        rawValue
    }
}

class BaseUITests: XCTestCase {
    lazy var app: XCUIApplication = {
        let app = XCUIApplication()
        return app
    }()

    func appLaunch(launchArguments: [String]) {
        app.launchArguments = launchArguments + ["onUITesting", "shouldDisableAnimations"]
        app.launch()
    }
}

extension BaseUITests {
    // Will fill user email and password.
    // User needs to be unauthenticated
    func auxiliar_performLogin() {
        exists(staticText: "Welcome", on: app)
        tap(
            textField: Accessibility.txtEmail.identifier,
            andType: "mail@gmail.com",
            dismissKeyboard: false,
            on: app
        )
        tap(
            secureTextField: Accessibility.txtPassword.identifier,
            andType: "123",
            dismissKeyboard: false,
            on: app
        )
        tap(button: Accessibility.loginButton.identifier, on: app)
    }

    // Will perform the onboarding flow.
    // User needs to authenticated, and on the correct flow
    func auxiliar_performOnBoarding() {
        //
        // User details screen
        //
        exists(staticText: "UserDetails", on: app)
        tap(
            textField: Accessibility.txtEmail.identifier,
            andType: "Testing Joe",
            dismissKeyboard: false,
            on: app
        )
        tap(
            button: Accessibility.fwdButton.identifier,
            andWaitForStaticText: "Terms & Conditions",
            on: app
        )
        //
        // Terms and Conditions screen
        //
        tap(button: Accessibility.readTermsAndConditions.identifier, on: app)
        tap(button: Accessibility.fwdButton.identifier, andWaitForStaticText: "Onboarding", on: app)

        //
        // Onboarding screen
        //
        tap(button: Accessibility.fwdButton.identifier, on: app) // Second
        tap(button: Accessibility.fwdButton.identifier, andWaitForStaticText: Constants.tab1ListItem, on: app) // Third
    }
}
