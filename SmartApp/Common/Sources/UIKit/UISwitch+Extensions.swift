//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UISwitch {
    /// Will simulate user touch
    func doTouchUpInside() {
        sendActions(for: .valueChanged)
    }
}
