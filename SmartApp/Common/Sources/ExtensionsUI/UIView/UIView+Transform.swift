//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public extension UIView {
    func animateBorderWidth(toValue: CGFloat, duration: Double) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = layer.borderWidth
        animation.toValue = toValue
        animation.duration = duration
        layer.add(animation, forKey: "Width")
        layer.borderWidth = toValue
    }

    func animateBorderColor(toValue: UIColor, duration: Double) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = toValue.cgColor
        animation.duration = duration
        layer.add(animation, forKey: "borderColor")
        layer.borderColor = toValue.cgColor
    }

    func addBorder(width: CGFloat, color: UIColor, animated: Bool) {
        if !animated {
            layer.borderWidth = width
            layer.borderColor = color.cgColor
            clipsToBounds = true
        } else {
            animateBorderColor(toValue: color, duration: Common.Constants.defaultAnimationsTime)
            animateBorderWidth(toValue: width, duration: Common.Constants.defaultAnimationsTime)
        }
    }

    func addCornerShape(corners: UIRectCorner = [.topLeft, .topRight], radius: CGFloat = 34) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.shouldRasterize = true
        mask.path = path.cgPath
        layer.mask = mask
    }

    func addCornerCurve(method: CALayerCornerCurve = .circular, radius: CGFloat = 34) {
        layer.cornerCurve = method // .continuous | .circular
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func addCorner(radius: CGFloat) {
        addCornerCurve(method: .circular, radius: radius)
    }

    // this functions is duplicated
    func addBlur(style: UIBlurEffect.Style = .dark) -> UIVisualEffectView {
        let blurEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.5
        addSubview(blurEffectView)
        return blurEffectView
    }

    func fadeTo(
        _ value: CGFloat,
        duration: Double = Common.Constants.defaultAnimationsTime,
        recursive: Bool = false,
        onCompletion: @escaping () -> Void = {}
    ) {
        if recursive {
            fadeTo(value, duration: duration, recursive: false, onCompletion: onCompletion)
            allSubviewsRecursive().forEach {
                $0.fadeTo(value, duration: duration, recursive: false, onCompletion: {})
            }
        } else {
            guard alpha != value else {
                onCompletion()
                return
            }

            UIView.animate(
                withDuration: duration,
                animations: { [weak self] in
                    self?.alpha = value
                },
                completion: { _ in
                    onCompletion()
                }
            )
        }
    }
}
