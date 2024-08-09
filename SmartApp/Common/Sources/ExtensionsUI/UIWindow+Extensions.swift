//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIWindow {
    static var firstWindow: UIWindow? {
        UIApplication.keyWindow
        // UIApplication.shared.windows.first
    }

    static var new: UIWindow {
        UIWindow.newWith(viewController: UIViewController())
    }

    static func newWith(viewController: UIViewController) -> UIWindow {
        let new = UIWindow(frame: UIScreen.main.bounds)
        new.windowLevel = .alert
        new.rootViewController = viewController
        new.rootViewController?.view.backgroundColor = .clear
        new.backgroundColor = .clear
        new.makeKeyAndVisible()
        return new
    }
}
