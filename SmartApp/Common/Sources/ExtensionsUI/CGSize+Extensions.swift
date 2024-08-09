//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension CGSize {
    func addPadding(width: CGFloat, height: CGFloat) -> CGSize {
        CGSize(width: self.width + width, height: self.height + height)
    }
}
