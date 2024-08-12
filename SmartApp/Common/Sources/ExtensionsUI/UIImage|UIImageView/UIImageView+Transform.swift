//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    /// Syntax sugar for [func changeImageColor(to color: UIColor)]
    func paintImageWith(color: UIColor) {
        changeImageColor(to: tintColor)
    }

    /// Turn image into template image, and apply color
    func changeImageColor(to color: UIColor) {
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }

    func toGrayScale() {
        if let newImage = image?.grayScaleV2 {
            image = newImage
        }
    }
}
