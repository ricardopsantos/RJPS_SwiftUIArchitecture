//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension Common {
    enum CachePolicy: String, CaseIterable {
        case ignoringCache
        case cacheElseLoad
        case cacheAndLoad
        case cacheDontLoad

        public var safeCachePolicyDueToInternetConnection: Self {
            if Common_Utils.existsInternetConnection() {
                self
            } else {
                .cacheDontLoad
            }
        }

        public var needsRemote: Bool {
            switch self {
            case .ignoringCache: true
            case .cacheElseLoad: true
            case .cacheAndLoad: true
            case .cacheDontLoad: false
            }
        }
    }
}
