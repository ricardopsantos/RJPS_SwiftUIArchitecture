//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public protocol CombineCompatibleProtocol {}

/// Extending the `UIControl` types to be able to produce a `UIControl.Event` publisher.
extension UIControl: CombineCompatibleProtocol {}

public extension UIControl {
    var combine: CombineCompatible { CombineCompatible(target: self) }
}

public struct CombineCompatible {
    public let target: UIControl
}
