//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension NSObject {
    var className: String { String(describing: type(of: self)) }
    static var className: String { String(describing: self) }
}
