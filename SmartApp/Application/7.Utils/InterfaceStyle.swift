//
//  AppearancePreference.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Core
import Common
import DesignSystem

//
// User Interface Style
//

struct InterfaceStyle {
    private static var selected: Common.InterfaceStyle?
    static var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    static func setupUserInterfaceStyle(nonSecureAppPreferences: NonSecureAppPreferencesProtocol?) {
        applyAppearance(current)
    }

    static var current: Common.InterfaceStyle? {
        get {
            if let selected = selected {
                return selected
            }
            if let selectedAppearance = nonSecureAppPreferences?.selectedAppearance {
                return Common.InterfaceStyle(rawValue: selectedAppearance)
            }
            return nil
        }
        set {
            applyAppearance(newValue)
        }
    }

    static func applyAppearance(_ style: Common.InterfaceStyle?) {
        guard style != selected else {
            return
        }
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    ColorSemantic.applyUserCustomInterfaceStyle(style)
                    selected = style
                    switch style {
                    case .light:
                        window.overrideUserInterfaceStyle = .light
                        nonSecureAppPreferences?.selectedAppearance = Common.InterfaceStyle.light.rawValue
                    case .dark:
                        window.overrideUserInterfaceStyle = .dark
                        selected = .dark
                        nonSecureAppPreferences?.selectedAppearance = Common.InterfaceStyle.dark.rawValue
                    case .none:
                        nonSecureAppPreferences?.selectedAppearance = nil
                        window.overrideUserInterfaceStyle = .unspecified
                    }
                }
            }
        }
    }
}
