//
//  Accessibility.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation

public enum Accessibility: String, CaseIterable {
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
