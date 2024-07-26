//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension Bool {
    var intValue: Int {
        self ? 1 : 0
    }

    static var `true`: Bool {
        true
    }

    static var `false`: Bool {
        false
    }
}
