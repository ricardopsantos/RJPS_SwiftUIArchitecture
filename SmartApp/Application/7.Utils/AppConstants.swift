//
//  Constants.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//
import Common

public enum AppConstants {
    static let weatherAppId = "1d8b7e6f3849be9a808176f247698ec3".decrypted
    static let countriesOptions = ["Portugal", "Spain", "Other"]
}

public extension AppConstants {
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

        // Not applied
        case undefined

        public var identifier: String {
            rawValue
        }
    }
}
