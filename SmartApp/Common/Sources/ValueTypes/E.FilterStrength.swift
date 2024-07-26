//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension Common {
    enum FilterStrength: CGFloat, CaseIterable {
        case none = 1
        case superLight = 0.95
        case regular = 0.75
        case heavyRegular = 0.6
        case almostHeavy = 0.3
        case heavy = 0.4
        case superHeavy = 0.1
    }
}
