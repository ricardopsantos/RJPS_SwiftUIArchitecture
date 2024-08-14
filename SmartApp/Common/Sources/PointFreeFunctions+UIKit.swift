//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit

var isRunningLive: Bool {
    #if targetEnvironment(simulator)
    return false
    #else
    let isRunningTestFlightBeta = (Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt")
    let hasEmbeddedMobileProvision = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
    if isRunningTestFlightBeta || hasEmbeddedMobileProvision {
        return false
    } else {
        return true
    }
    #endif
}

// Screen width.
public var screenWidth: CGFloat { screenSize.width }
public var screenHeight: CGFloat { screenSize.height }
public var screenSize: CGSize { UIScreen.main.bounds.size }
public var safeAreaTop: CGFloat { UIWindow.firstWindow?.safeAreaInsets.top ?? 0 }
public var safeAreaBottom: CGFloat { UIWindow.firstWindow?.safeAreaInsets.bottom ?? 0 }
