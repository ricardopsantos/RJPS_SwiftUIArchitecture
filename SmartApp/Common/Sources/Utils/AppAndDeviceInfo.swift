//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - iOS/MacOs

public extension Common {
    struct AppInfo {
        private init() {}
        public static var supportsMultipleScene: Bool { UIApplication.shared.supportsMultipleScenes }
        public static var supportsAlternateIcons: Bool { UIApplication.shared.supportsAlternateIcons }
        public static var supportsShakeToEdit: Bool { UIApplication.shared.applicationSupportsShakeToEdit }
        public static var version: String {
            if let bundleVersion = Bundle.bundleVersion,
               let bundleShortVersion = Bundle.bundleShortVersion {
                return "\(bundleShortVersion) (\(bundleVersion))"
            }
            return ""
        }

        public static var bundleIdentifier: String { Bundle.main.bundleIdentifier ?? "" }
        public static var onBackground: Bool {
            let appState = UIApplication.shared.applicationState
            return appState == .background || appState == .inactive
        }
    }

    struct DeviceInfo {
        private init() {}
        public static var machineInfo: String { UIDevice.machineNameInfo }
        public static var operatingSystemVersionString: String {
            ProcessInfo().operatingSystemVersionString
        }

        public static var systemVersion: String { UIDevice.current.systemVersion }
        public static var name: String { UIDevice.current.name }
        public static var systemName: String { UIDevice.current.systemName }
        public static var model: String { UIDevice.current.model }
        public static var iPadDevice: Bool { UIDevice.current.userInterfaceIdiom == .pad }
        public static var iPhoneDevice: Bool { UIDevice.current.userInterfaceIdiom == .phone }
        public static var batteryState: String {
            switch UIDevice.current.batteryState {
            case .charging: "Charging"
            case .full: "Full"
            case .unplugged: "Unplugged"
            default: "Unknown"
            }
        }

        public static func setBatteryMonitoring(to value: Bool) -> Bool {
            UIDevice.current.isBatteryMonitoringEnabled = true
            return isBatteryMonitoringEnabled
        }

        public static var isBatteryMonitoringEnabled: Bool {
            UIDevice.current.isBatteryMonitoringEnabled
        }

        public static var batteryIsInLowPower: Bool {
            ProcessInfo.processInfo.isLowPowerModeEnabled
        }

        public static var batteryLevel: String {
            guard isBatteryMonitoringEnabled else {
                return "Unknown"
            }

            let battery = UIDevice.current.batteryLevel
            if battery == -1 {
                return "Unknown"
            }
            return "\(battery.formatted(.percent))"
        }

        public static var uuid: String { UIDevice.current.identifierForVendor!.uuidString }
        public static var isSimulator: Bool {
            #if targetEnvironment(simulator)
            return true
            #else
            return false
            #endif
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct AppInfo: View {
        public init() {}
        public var body: some View {
            VStack {
                Group {
                    Text("App Supports Multiple Scene: \(Common.AppInfo.supportsMultipleScene.description)")
                    Text("App Supports Alternate Icons: \(Common.AppInfo.supportsAlternateIcons.description)")
                    Text("App Supports Shake To Edit: \(Common.AppInfo.supportsShakeToEdit.description)")
                }
                Divider()
                Group {
                    Text("Machine Info: \(Common.DeviceInfo.machineInfo)")
                    Text("Device Name: \(Common.DeviceInfo.name)")
                    Text("System Name: \(Common.DeviceInfo.systemName)")
                    Text("Device Model: \(Common.DeviceInfo.model)")
                    Text("System Version 1: \(Common.DeviceInfo.systemVersion)")
                    Text("System Version 2: \(Common.DeviceInfo.operatingSystemVersionString)")
                    Text("Battery Charging State: \(Common.DeviceInfo.batteryState)")
                    Text("Battery Monitoring Enabled: \(Common.DeviceInfo.isBatteryMonitoringEnabled.description)")
                    Text("Battery Monitoring Enabled (After change)? \(Common.DeviceInfo.setBatteryMonitoring(to: true).description)")
                    Text("Battery Charge Level: \(Common.DeviceInfo.batteryLevel)")
                }
                Spacer()
            }
        }
    }
}

#Preview {
    Common_Preview.AppInfo()
}
#endif
