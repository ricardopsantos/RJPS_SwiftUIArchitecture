//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension Common {
    enum AppTags: Int {
        case na = 1

        // base
        case view
        case containerView
        case loadingView
        case viewContainer
        case button
        case label
        case imageView
        case scrollView
        case table
        case stackView
        case stackViewVisibleSeparatorLine
        case stackViewInvisibleSeparatorLine
        case textField
        case shadowView
        case designableContainerView
        case coverView

        public var tag: Int { rawValue }
    }
}
