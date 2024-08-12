//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension NetworkAgentSampleNamespace.RequestDto {
    struct Employee {
        public let someParam: String
        public init(someParam: String) {
            self.someParam = someParam
        }
    }
}
