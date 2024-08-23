//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Common

public enum HitHappensEventCategory: Int, CaseIterable, Hashable, Sendable {
    case none = 0
    case health
    case lifestyle
    case professional
    case personal
}
