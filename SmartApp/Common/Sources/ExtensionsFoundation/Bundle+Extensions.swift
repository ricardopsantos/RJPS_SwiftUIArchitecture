//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension Bundle {
    static var bundleVersion: String? {
        main.bundleVersion
    }

    static var bundleShortVersion: String? {
        main.bundleShortVersion
    }

    var bundleVersion: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }

    var bundleShortVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
