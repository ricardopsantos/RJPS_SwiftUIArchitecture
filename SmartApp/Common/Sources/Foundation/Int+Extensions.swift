//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension Int {
    var boolValue: Bool {
        self != 0
    }
    
    var localeString: String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.isLenient = true
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
}
