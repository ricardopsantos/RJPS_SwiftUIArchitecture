//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIDevice {
    enum DeviceSizeForVerticalAppearance: String {
        case compact // Device Size W / H < 2 : Smaller devices
        case regular // Device Size W / H > 2 : Long and bigger devices
    }

    enum DeviceSize: String {
        case xSmall
        case small
        case mini
        case regular
        case large
        case xLarge
        case xxLarge
    }

    static var isSmallOrMedium: Bool {
        Self.is(.xSmall) || Self.is(.small) || Self.is(.mini) || Self.is(.regular)
    }

    static var isLargeOrXLarge: Bool {
        !isSmallOrMedium
    }

    static func `is`(_ value: UIDevice.DeviceSize) -> Bool {
        value == deviceSize
    }

    static var deviceSizeForVerticalAppearance: DeviceSizeForVerticalAppearance = {
        //
        // xSmall   : (375.0, 667.0) -> 1.778 ratio : 8, SE
        // small    : (414.0, 736.0) -> 1.842 ratio : 8+
        // mini     : (375.0, 812.0) -> 2.165 ratio : 11 Pro, 12 Mini, 13 Mini, X, Xs, 14
        // regular  : (390.0, 844.0) -> 2.164 ratio : 12, 12 Pro, 13 Pro
        // large    : (414.0, 896.0) -> 2.164 ratio : 11, 11 Pro Max, 11 Xr, 11 Xs, 11 Max
        // xLarge   : (428.0, 926.0) -> 2.164 ratio : 12 Pro Max, 13 Pro Max, 14 Plus
        // xxLarge  : (430.0, 932.0) -> 2.167 ratio : 14 Pro MaxP
        //

        let height = UIScreen.main.bounds.size.height
        let width = UIScreen.main.bounds.size.width
        let ratio = height / width
        if ratio < 2 {
            return .compact
        } else {
            return .regular
        }
    }()

    static var deviceSize: DeviceSize = {
        //
        // xSmall   : (375.0, 667.0) -> 1.778 ratio : 8, SE
        // small    : (414.0, 736.0) -> 1.842 ratio : 8+
        // mini     : (375.0, 812.0) -> 2.165 ratio : 11 Pro, 12 Mini, 13 Mini, X, Xs, 14
        // regular  : (390.0, 844.0) -> 2.164 ratio : 12, 12 Pro, 13 Pro
        // large    : (414.0, 896.0) -> 2.164 ratio : 11, 11 Pro Max, 11 Xr, 11 Xs, 11 Max
        // xLarge   : (428.0, 926.0) -> 2.164 ratio : 12 Pro Max, 13 Pro Max, 14 Plus
        // xxLarge  : (430.0, 932.0) -> 2.167 ratio : 14 Pro MaxP
        //

        let height = UIScreen.main.bounds.size.height
        let width = UIScreen.main.bounds.size.width

        if height <= 667 {
            return .xSmall
        } else if height <= 736 {
            return .small
        } else if height <= 812 {
            return .mini
        } else if height <= 844 {
            return .regular
        } else if height <= 896 {
            return .large
        } else if height <= 926 {
            return .xLarge
        } else {
            return .xxLarge
        }
    }()

    var machineName: String {
        UIDevice.machineNameInfo
    }

    static let machineNameInfo: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }()
}
