//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIScrollView {
    var view: UIView { self as UIView }

    static func defaultScrollView() -> UIScrollView {
        let some = UIScrollView()
        some.isUserInteractionEnabled = true
        some.isScrollEnabled = true
        some.autoresizesSubviews = false
        some.translatesAutoresizingMaskIntoConstraints = false
        some.clipsToBounds = false // Avoiding crops shadows of inner elements
        return some
    }

    func scrollToTop(animated: Bool) {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: animated)
    }

    func scrollToBottom(animated: Bool) {
        let desiredOffset = CGPoint(x: 0, y: contentInset.bottom)
        setContentOffset(desiredOffset, animated: animated)
    }

    // Starts on page 1
    func scrollTo(horizontalPage: CGFloat? = 0, verticalPage: CGFloat? = 0, animated: Bool? = true) {
        var frameCopy: CGRect = frame
        frameCopy.origin.x = frameCopy.size.width * CGFloat(horizontalPage ?? 0)
        frameCopy.origin.y = frameCopy.size.width * CGFloat(verticalPage ?? 0)
        scrollRectToVisible(frameCopy, animated: animated ?? true)
    }
}

fileprivate extension UIScrollView {}
