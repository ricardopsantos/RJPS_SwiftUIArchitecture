//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

public extension UIScreen {
    static var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
    static var screenHeight: CGFloat { UIScreen.main.bounds.size.height }
    static var screenSize: CGSize { UIScreen.main.bounds.size }

    static var safeAreaTopInset: CGFloat {
        if let topSafeAreaMagnitude = UIWindow.firstWindow?.safeAreaInsets.top {
            topSafeAreaMagnitude
        } else {
            UIDevice.isLargeOrXLarge ? 48 : 20
        }
    }

    static var safeAreaBottomInset: CGFloat { UIWindow.firstWindow?.safeAreaInsets.bottom ?? 0 }
}
