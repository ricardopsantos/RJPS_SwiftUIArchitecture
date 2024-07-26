//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension Common {
    enum InterfaceStyle: String, CaseIterable {
        public init?(rawValue: String) {
            if let some = Self.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) {
                self = some
            } else {
                return nil
            }
        }

        case light
        case dark

        public static var current: InterfaceStyle {
            UIView().traitCollection.userInterfaceStyle == .dark ? .dark : .light
        }

        public var intValue: Int {
            switch self {
            case .light: 1
            case .dark: 2
            }
        }

        public static var alternative: InterfaceStyle {
            current == .dark ? .light : .dark
        }
    }
}
