//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public extension UIView {
    func bringToFront() { superview?.bringSubviewToFront(self) }

    func sendToBack() { superview?.sendSubviewToBack(self) }

    var erased: AnyView {
        asAnyView
    }
}

public extension UIView {
    var screenHeightSafe: CGFloat {
        screenHeight - safeAreaInsets.bottom.magnitude - safeAreaInsets.top.magnitude
    }

    // Find super views of type
    func superview<T>(of type: T.Type) -> T? {
        superview as? T ?? superview.flatMap { $0.superview(of: type) }
    }

    var asAnyView: AnyView {
        Common_ViewRepresentable { self }.erased
    }

    var asImage: UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }

        return image
    }

    var printableMemoryAddress: String {
        // https://stackoverflow.com/questions/24058906/printing-a-variable-memory-address-in-swift
        "\(Unmanaged.passUnretained(self).toOpaque())"
    }

    var width: CGFloat { frame.width }
    var height: CGFloat { frame.height }

    var viewController: UIViewController? {
        if let nextResponder = next as? UIViewController {
            return nextResponder
        }
        if let nextResponder = next as? UIView {
            return nextResponder.viewController
        }
        return nil
    }

    func disableUserInteractionFor(_ seconds: Double, disableAlpha: CGFloat = 1) {
        guard isUserInteractionEnabled else {
            return
        }
        guard seconds > 0 else {
            return
        }
        isUserInteractionEnabled = false
        alpha = disableAlpha
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(seconds)) { [weak self] in
            self?.isUserInteractionEnabled = true
            self?.alpha = 1
        }
    }
}
