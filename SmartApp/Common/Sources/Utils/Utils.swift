//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
#if !os(watchOS)
import SystemConfiguration
#endif
import UIKit

public extension Common {
    struct Utils {
        private init() {}

        public static var `true`: Bool { true }
        public static var `false`: Bool { false }

        public static func onceWithDelay(token: String, block: @escaping () -> Void) {
            DispatchQueue.executeOnce(token: token, block: {
                DispatchQueue.executeWithDelay { block() }
            })
        }

        public static func delay(_ delay: Double = 0.1, block: @escaping () -> Void) {
            DispatchQueue.executeWithDelay(delay: delay) { block() }
        }

        public static func executeWithDebounce(
            _ timeInterval: TimeInterval,
            operationId: String,
            closure: @escaping () -> Void
        ) {
            Common.ExecutionControlManager.debounce(
                timeInterval,
                operationId: operationId,
                closure: closure
            )
        }

        public static func executeWithThrottle(
            _ timeInterval: TimeInterval,
            operationId: String,
            closure: () -> Void,
            onIgnoredClosure: () -> Void = {}
        ) {
            Common.ExecutionControlManager.throttle(
                timeInterval,
                operationId: operationId,
                closure: closure,
                onIgnoredClosure: onIgnoredClosure
            )
        }

        @discardableResult
        public static func executeOnce(token: String, block: () -> Void, onIgnoredClosure: () -> Void = {}) -> Bool {
            DispatchQueue.executeOnce(token: token, block: { block() }, onIgnoredClosure: onIgnoredClosure)
        }

        public static var onUnitTests: Bool {
            ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        }

        public static var onUITests: Bool {
            if ProcessInfo.processInfo.environment["UITestRunner"] == "1" {
                return true
            }
            if ProcessInfo.processInfo.environment["XCUI_TESTING"] == "1" {
                return true
            }
            return false
        }

        public static func executeInMainTread(_ block: @escaping () -> Void) {
            DispatchQueue.executeInMainTread { block() }
        }

        public static func executeInUserInteractiveTread(_ block: @escaping () -> Void) {
            DispatchQueue.executeInUserInteractiveTread { block() }
        }

        public static func executeInBackgroundTread(_ block: @escaping () -> Void) {
            DispatchQueue.executeInBackgroundTread { block() }
        }

        public static var onRelease: Bool {
            !onDebug
        }

        public static var onDebug: Bool {
            #if DEBUG
            // For Simulator, and apps created with Xcode
            return true
            #else
            // For AppStore and Archive
            return false
            #endif
        }

        public static var onDevice: Bool {
            !onSimulator
        }

        public static var onSimulator: Bool {
            #if targetEnvironment(simulator)
            return true
            #else
            return false
            #endif
        }

        // Just for iPhone simulator
        public static var isSimulator: Bool { Common.DeviceInfo.isSimulator }
        public static var isRealDevice: Bool { !isSimulator }

        public static func senderCodeId(
            _ function: String = #function,
            file: String = #file,
            line: Int = #line,
            showLine: Bool = isRealDevice
        ) -> String {
            let fileName = file.split(by: "/").last!
            var sender = "\(fileName), func/var \(function)"
            if showLine {
                sender = "\(sender), line \(line)"
            }
            return sender
        }

        public static func existsInternetConnection(_ method: CommonNetworking.Reachability.Method = .default) -> Bool {
            CommonNetworking.Reachability.isConnectedToNetwork(method)
        }

        // https://www.swiftbysundell.com/posts/under-the-hood-of-assertions-in-swift
        // @autoclosure to avoid evaluating expressions in non-debug configurations
        public static func assert(
            _ value: @autoclosure () -> Bool,
            message: @autoclosure () -> String = "",
            function: StaticString = #function,
            file: StaticString = #file,
            line: Int = #line
        ) {
            guard onDebug else {
                return
            }
            if !value() {
                LogsManager.error(
                    "Assert condition not meeted! \(message())" as AnyObject,
                    function: "\(function)",
                    file: "\(file)",
                    line: line
                )
            }
        }
    }
}
