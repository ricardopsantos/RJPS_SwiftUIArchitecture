//
//  Constants.swift
//  SmartAppUITests
//
//  Created by Ricardo Santos on 08/08/2024.
//

import Foundation
import Common

let cancelBag = CancelBag()
var timeout: Int = 5
var loadedAny: Any?

enum Constants {
    static let tab1Title = "Current Weather"
    static let tab1DetailsTitle = "Weather Details"
    static let tab1DetailsValue = "32 °C"
    static let tab1ListItem1 = "Lisbon"
    static let tab1ListItem2 = "Paris"
    static let tab1ListItem3 = "New York"
    //
    static let tab2Title = "USA Population: Last 45 years"
    static let tab2DetailsTitle = "USA States Population for 1980"
    static let tab2ListItem = "Year: 1980"
    //
    static let tab4Title = "Settings"
    // Tabs
    static let tabBarWeather = 0
    static let tabBarUSAStats = 1
    static let tabBar3 = 2
    static let tabBarSettings = 3
}

//
// Copy of `UITestingManager.Options` enum @ SmartApp Target
// Copy of `UITestingManager.Options` enum @ SmartApp Target
// Copy of `UITestingManager.Options` enum @ SmartApp Target
//
enum UITestingOptions: String {
    case onUITesting
    case shouldDisableAnimations
    case shouldResetAllPreferences
    case isAuthenticated
}

//
// Copy of `Accessibility` enum @ SmartApp Target
// Copy of `Accessibility` enum @ SmartApp Target
// Copy of `Accessibility` enum @ SmartApp Target
//
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
