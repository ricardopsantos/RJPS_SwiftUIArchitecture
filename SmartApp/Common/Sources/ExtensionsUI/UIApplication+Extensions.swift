//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import SwiftUI

public extension UIApplication {
    func dismissKeyboard() {
        endEditing(true)
    }

    func resignFirstResponder() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func endEditing(_ force: Bool) {
        // windows.first(where: \.isKeyWindow)?.endEditing(force)
        // windows.filter { $0.isKeyWindow }.first?.endEditing(force)
        Self.keyWindow?.endEditing(force)
    }

    static var keyWindow: UIWindow? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter(\.isKeyWindow).first
        return keyWindow
    }

    var topViewController: UIViewController? {
        UIApplication.topViewController()
    }

    class func topViewController(base: UIViewController? = UIApplication.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    var isInBackgroundOrInactive: Bool {
        switch applicationState {
        case .background,
             .inactive:
            true
        case .active:
            false
        default:
            false
        }
    }

    static func openAppSettings() {
        guard let appSettings = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
    }
}
