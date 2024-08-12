//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

/**
 # Taken from Composable Architecture Examples:
 https://github.com/pointfreeco/swift-composable-architecture/blob/c1f88bd8608e8a26fd61ab46c9f11a63b0f4023d/Examples/CaseStudies/SwiftUICaseStudies/03-Effects-SystemEnvironment.swift#L216
 */

public extension UUID {
    /// A deterministic, auto-incrementing "UUID" generator for testing.
    static var incrementing: () -> UUID {
        var uuid = 0
        return {
            defer { uuid += 1 }
            return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuid))")!
        }
    }
}
