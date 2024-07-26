//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIButton {
    /// Will simulate user touch
    func doTouchUpInside() {
        sendActions(for: .touchUpInside)
    }

    func paintImage(with color: UIColor) {
        changeImageColor(to: color)
    }

    /// Turn image into template image, and apply color
    func changeImageColor(to color: UIColor) {
        guard let origImage = image(for: state) else {
            return
        }
        let tintedImage = origImage.withRenderingMode(.alwaysTemplate)
        setImageForAllStates(tintedImage, tintColor: color)
        tintColor = color
    }

    func setImageForAllStates(_ image: UIImage, tintColor: UIColor?) {
        let tintedImage = (tintColor != nil) ? image.withRenderingMode(.alwaysTemplate) : image
        setImage(tintedImage, for: .normal)
        setImage(tintedImage, for: .disabled)
        setImage(tintedImage, for: .highlighted)
        setImage(tintedImage, for: .focused)
        if tintColor != nil {
            self.tintColor = tintColor
        }
    }

    func disable() {
        isUserInteractionEnabled = false
        fadeTo(0.6)
    }

    func enable() {
        isUserInteractionEnabled = true
        fadeTo(1)
    }

    func setTitleForAllStates(_ title: String) {
        setTitle(title, for: .normal)
        setTitle(title, for: .highlighted)
        setTitle(title, for: .selected)
    }

    func setTextColorForAllStates(_ color: UIColor) {
        titleLabel?.textColor = color
        setTitleColor(color, for: .normal)
        setTitleColor(color.alpha(0.25), for: .highlighted)
        setTitleColor(color, for: .selected)
    }
    /*
     func onTouchUpInside(autoDisableUserInteractionFor: Double = 1, block: @escaping () -> Void) {
         class ClosureSleeve {
             let block: () -> Void
             init(_ block: @escaping () -> Void) {
                 self.block = block
             }
             @objc func invoke() { block() }
         }
         (self as UIView).disableUserInteractionFor(autoDisableUserInteractionFor)
         let sleeve = ClosureSleeve(block)
         addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: .touchUpInside)
         objc_setAssociatedObject(self, "[\(arc4random())]", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
     }*/
}

//
// MARK: - Animations
//

public extension UIButton {
    // When tapped, will animate the button background
    // Animation: Rounded background that will decrease in shape and opacity
    func applyTapBackgroundAnimation(expandedSize: CGFloat = 1.25) {
        isEnabled = false
        let duration: CGFloat = Common.Constants.defaultAnimationsTime * 2.0
        // Calculate the expanded size for the background layer
        let expandedSize = CGSize(
            width: bounds.width * expandedSize,
            height: bounds.height * expandedSize
        )

        // Create a new layer for the background circle
        let backgroundLayer = CALayer()
        backgroundLayer.bounds = CGRect(origin: .zero, size: expandedSize)
        backgroundLayer.position = center
        backgroundLayer.cornerRadius = expandedSize.width / 2 // Make it a circle
        backgroundLayer.backgroundColor = Common.InterfaceStyle.current == .light ?
            UIColor.white.alpha(0.5).cgColor :
            UIColor.black.alpha(0.5).cgColor

        // Insert the background layer behind the button's layer
        if let buttonIndex = superview?.layer.sublayers?.firstIndex(of: layer) {
            superview?.layer.insertSublayer(backgroundLayer, at: UInt32(buttonIndex))
        }

        // Create the scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1 // Start with full size
        scaleAnimation.toValue = 0.5 // Scale down to nothing
        scaleAnimation.duration = duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Create the fade-out animation
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.fromValue = 1 // Start with full opacity
        fadeOutAnimation.toValue = 0 // Fade out to completely transparent
        fadeOutAnimation.duration = duration
        fadeOutAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Group both animations together
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, fadeOutAnimation]
        animationGroup.duration = duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Add the animation to the background layer
        backgroundLayer.add(animationGroup, forKey: "scaleAndFadeAnimation")

        // Remove the background layer after the animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.8) { [weak self] in
            backgroundLayer.removeFromSuperlayer()
            self?.isEnabled = true // Re-enable the button after the animation
        }
    }
}
