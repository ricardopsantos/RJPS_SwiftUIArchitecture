//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    enum CommonViewAnimations {
        case bump
        case fadeOutAndIn
        case shake
    }

    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.repeatCount = 2
        shake.autoreverses = true
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        shake.fromValue = fromValue
        shake.toValue = toValue
        layer.add(shake, forKey: "position")
    }

    func perform(
        animation: CommonViewAnimations,
        disableUserInteractionFor: Double = 1,
        block: @escaping () -> Void
    ) {
        switch animation {
        case .bump:
            bumpAndPerform(disableUserInteractionFor: disableUserInteractionFor, block: block)
        case .fadeOutAndIn:
            fadeAndPerform(disableUserInteractionFor: disableUserInteractionFor, block: block)
        case .shake:
            ()
        }
    }
}

fileprivate extension UIView {
    func fadeAndPerform(
        disableUserInteractionFor: Double = 1,
        block: @escaping () -> Void
    ) {
        (self as UIView).disableUserInteractionFor(disableUserInteractionFor)
        UIView.animate(
            withDuration: Common.Constants.defaultAnimationsTime / 2.0,
            animations: { [weak self] in
                guard let self else {
                    return
                }
                alpha = 0.66
            },
            completion: { _ in
                UIView.animate(
                    withDuration: Common.Constants.defaultAnimationsTime / 2.0,
                    animations: { self.alpha = 1 },
                    completion: { _ in
                        block()
                    }
                )
            }
        )
    }

    func bumpAndPerform(
        scale: CGFloat = Common.Constants.defaultScaleOnTap,
        disableUserInteractionFor: Double = 1,
        block: @escaping () -> Void
    ) {
        (self as UIView).disableUserInteractionFor(disableUserInteractionFor)
        UIView.animate(
            withDuration: Common.Constants.defaultAnimationsTime / 2.0,
            animations: { [weak self] in
                guard let self else {
                    return
                }
                transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: Common.Constants.defaultAnimationsTime / 2.0,
                    animations: { self.transform = .identity },
                    completion: { _ in
                        block()
                    }
                )
            }
        )
    }
}
