//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
@testable import Common

public extension RequestDto {
    struct Employee: Codable {
        public let id: String
        public init(id: String) {
            self.id = id
        }
    }
}
