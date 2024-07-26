//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    var topViewController: UIViewController? {
        UIViewController.topViewController
    }

    static var topViewController: UIViewController? {
        UIApplication.topViewController()
    }

    var isVisible: Bool { isViewLoaded && (view.window != nil) }

    var genericAccessibilityIdentifier: String {
        // One day we will have Accessibility on the app, and we will be ready....
        let name = String(describing: type(of: self))
        return "accessibilityIdentifierPrefix.\(name)"
    }

    static var applicationLoadedViewControllers: (
        tabBarControllers: [UITabBarController],
        navigationControllers: [UINavigationController],
        viewControllers: [UIViewController]
    ) {
        let loadedViewControllersAndLevels = applicationLoadedViewControllersAndLevels
        return (
            loadedViewControllersAndLevels.tabBarControllers.map(\.controller),
            loadedViewControllersAndLevels.navigationControllers.map(\.controller),
            loadedViewControllersAndLevels.viewControllers.map(\.controller)
        )
    }

    static var applicationLoadedViewControllersAndLevels: (
        tabBarControllers: [(controller: UITabBarController, level: Int)],
        navigationControllers: [(controller: UINavigationController, level: Int)],
        viewControllers: [(controller: UIViewController, level: Int)]
    ) {
        var allViewControllersAndLevels: [(viewController: UIViewController, level: Int)] = []
        var tabBarControllersAndLevels: [(controller: UITabBarController, level: Int)] = []
        var navigationControllersAndLevels: [(controller: UINavigationController, level: Int)] = []
        var viewControllersAndLevels: [(controller: UIViewController, level: Int)] = []
        if let rootViewController = UIApplication.keyWindow?.rootViewController {
            // Recursive function to traverse through view controller hierarchy
            func addViewControllers(from viewController: UIViewController, level: Int) {
                allViewControllersAndLevels.append((viewController, level))
                if let navigationController = viewController as? UINavigationController {
                    for viewController in navigationController.viewControllers {
                        addViewControllers(from: viewController, level: level + 1)
                    }
                } else if let tabBarController = viewController as? UITabBarController {
                    for viewController in tabBarController.viewControllers ?? [] {
                        addViewControllers(from: viewController, level: level + 1)
                    }
                } else if let presentedViewController = viewController.presentedViewController {
                    addViewControllers(from: presentedViewController, level: level + 1)
                }
            }
            addViewControllers(from: rootViewController, level: 0)
        }
        allViewControllersAndLevels.forEach { viewControllerAndLevel in
            if let tabBarController = viewControllerAndLevel.viewController as? UITabBarController {
                tabBarControllersAndLevels.append((tabBarController, viewControllerAndLevel.level))
            } else if let navigationController = viewControllerAndLevel.viewController as? UINavigationController {
                navigationControllersAndLevels.append((navigationController, viewControllerAndLevel.level))
            } else {
                viewControllersAndLevels.append((viewControllerAndLevel.viewController, viewControllerAndLevel.level))
            }
        }
        tabBarControllersAndLevels = tabBarControllersAndLevels.sorted(by: { a, b in a.level < b.level })
        navigationControllersAndLevels = navigationControllersAndLevels.sorted(by: { a, b in a.level < b.level })
        viewControllersAndLevels = viewControllersAndLevels.sorted(by: { a, b in a.level < b.level })
        return (
            tabBarControllersAndLevels,
            navigationControllersAndLevels,
            viewControllersAndLevels
        )
    }
}
