//
//  DevTools.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
import UIKit
//
import Common

public enum DevTools {
    // public static var onDarkMode: Bool { UIView().traitCollection.userInterfaceStyle == .dark }
    // public static var onLightMode: Bool { UIView().traitCollection.userInterfaceStyle == .light }
    public static var onRunningPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    public static var targetEnv: String {
        guard let value = (Bundle.main.infoDictionary?["TARGET_ENVIRONMENT"] as? String)?
            .replacingOccurrences(of: "\\", with: "") else {
            return ""
        }
        return value
    }

    public static var onTargetDev: Bool { targetEnv.lowercased() == "dev" }
    public static var onTargetQA: Bool { targetEnv.lowercased() == "qa" }
    public static var onTargetProduction: Bool { targetEnv.lowercased() == "production" }
    public static var onSimulator: Bool { Common_Utils.onSimulator }
    public static var onUnitTests: Bool { Common_Utils.onUnitTests }
}

public extension DevTools {
    static func assertFailure(
        _ message: @autoclosure () -> String,
        function: StaticString = #function,
        forceFix: Bool,
        file: StaticString = #file,
        line: Int = #line
    ) {
        DevTools.assert(false, message: message(), forceFix: forceFix, function: function, file: file, line: line)
    }

    static func assert(
        _ value: @autoclosure () -> Bool,
        message: @autoclosure () -> String = "",
        forceFix: Bool = false,
        function: StaticString = #function,
        file: StaticString = #file,
        line: Int = #line
    ) {
        guard !DevTools.onTargetProduction else {
            return
        }
        if !value() {
            Log.error(
                "Assert condition not meted! \(message())",
                .generic,
                function: "\(function)",
                file: "\(file)",
                line: line
            )
            if forceFix, DevTools.onSimulator, !DevTools.onUnitTests {
                fatalError("Fix me \(file)|\(function)|\(line)")
            }
        }
    }
}
