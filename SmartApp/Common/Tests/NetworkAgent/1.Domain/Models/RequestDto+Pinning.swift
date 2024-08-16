//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
@testable import Common

public extension RequestDto {
    struct Pinning {
        public let someParam: String
        public init(someParam: String = "") {
            self.someParam = someParam
        }
    }
}
