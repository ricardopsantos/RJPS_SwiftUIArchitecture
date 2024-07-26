//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    var allSubviews: [UIView] { allSubviewsRecursive() }
    func removeAllSubviewsRecursive() {
        let allViews = UIView.allSubviewsRecursive(from: self) as [UIView]
        _ = allViews.map { some in
            if let viewController = some.viewController {
                viewController.destroy()
            }
            some.removeFromSuperview()
        }
    }

    func allSubviewsWith(type: AnyClass) -> [UIView] {
        allSubviews.filter { $0.isKind(of: type) }
    }

    func allSubviewsWith(tag: Int, recursive: Bool) -> [UIView] {
        if recursive {
            UIView.allSubviewsRecursive(from: self).filter { $0.tag == tag }
        } else {
            subviews.filter { $0.tag == tag }
        }
    }

    class func allSubviewsRecursive<T: UIView>(from view: UIView) -> [T] {
        view.subviews.flatMap { subView -> [T] in
            var result = allSubviewsRecursive(from: subView) as [T]
            if let view = subView as? T {
                result.append(view)
            }
            return result
        }
    }

    func allSubviewsRecursive<T: UIView>() -> [T] { UIView.allSubviewsRecursive(from: self) as [T] }
}
