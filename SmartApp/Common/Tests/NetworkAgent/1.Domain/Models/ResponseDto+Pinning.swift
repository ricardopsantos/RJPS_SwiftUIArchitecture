//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
@testable import Common

public extension ResponseDto {
    struct Pinning: Codable, Hashable {
        public let codConcelho: String?

        enum CodingKeys: String, CodingKey {
            case codConcelho = "cod_concelho"
        }
    }
}
