//
//  InterfaceStyle.swift
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
import DevTools

struct InterfaceStyleManager {
    private static var selected: Common.InterfaceStyle?
    static var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    static func setup(nonSecureAppPreferences: NonSecureAppPreferencesProtocol?) {
        Self.nonSecureAppPreferences = nonSecureAppPreferences
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
        DevTools.assert(nonSecureAppPreferences != nil, message: "nonSecureAppPreferences not set")
        guard style != selected else {
            return
        }
        Common_Utils.executeInMainTread {
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
