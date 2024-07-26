//
//  Created by Santos, Ricardo Patricio dos  on 02/06/2021.
//

import Foundation
import UIKit

public extension UINavigationController {
    func setNavigationBarColor(_ color: UIColor) {
        if color.extractAlpha != 1.0 {
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.isTranslucent = true
            navigationBar.backgroundColor = color
        } else {
            navigationBar.isTranslucent = false
        }
        navigationBar.barTintColor = color
    }

    func removeShadowAndHairline() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        hideHairline()
        navigationBar.layoutIfNeeded()
    }

    func restoreShadowAndHairline() {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
        restoreHairline()
        navigationBar.layoutIfNeeded()
    }

    func hideHairline() {
        if let hairline = findHairlineImageViewUnder(navigationBar) {
            hairline.isHidden = true
        }
    }

    func restoreHairline() {
        if let hairline = findHairlineImageViewUnder(navigationBar) {
            hairline.isHidden = false
        }
    }

    func findHairlineImageViewUnder(_ view: UIView) -> UIImageView? {
        if view is UIImageView, view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            if let imageView = findHairlineImageViewUnder(subview) {
                return imageView
            }
        }
        return nil
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }

    func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }

    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}
