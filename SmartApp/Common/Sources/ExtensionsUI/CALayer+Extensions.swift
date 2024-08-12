//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension CALayer {
    /// Usage: `view.layer.configureGradientBackground(UIColor.purple.cgColor, UIColor.blue.cgColor, UIColor.white.cgColor)`
    @discardableResult
    func addVerticalGradientBackground(_ colors: CGColor...) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        let maxWidth = max(bounds.size.height, bounds.size.width)
        let squareFrame = CGRect(origin: bounds.origin, size: CGSize(width: maxWidth, height: maxWidth))
        gradient.frame = squareFrame
        gradient.colors = colors
        insertSublayer(gradient, at: 0)
        return gradient
    }

    @discardableResult
    func addHorizontalGradientBackground(_ colors: CGColor...) -> CAGradientLayer {
        let horizontalGradient: CAGradientLayer = {
            let gradient = CAGradientLayer()
            gradient.type = .axial
            gradient.colors = colors
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            // gradient.locations = [0, 1]
            gradient.frame = bounds
            return gradient
        }()
        insertSublayer(horizontalGradient, at: 0)
        return horizontalGradient
    }
}
