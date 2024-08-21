//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import UIKit

internal class CommonBundleFinder {}

public extension Common {
    static var internalDB: String { "CommonDB" }
    static var bundleIdentifier: String {
        Bundle(for: CommonBundleFinder.self).bundleIdentifier ?? ""
    }

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: "\(Common.bundleIdentifier)")
        // .standard
    }
}
