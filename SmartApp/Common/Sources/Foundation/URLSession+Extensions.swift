//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Network

public extension URLSession {
    static var defaultForNetworkAgent: URLSession {
        defaultWithConfig(
            waitsForConnectivity: false,
            timeoutIntervalForResource: defaultTimeoutIntervalForResource,
            cacheEnabled: false
        )
    }

    static var defaultTimeoutIntervalForResource: TimeInterval { 60 }

    static func defaultWithConfig(
        waitsForConnectivity: Bool,
        timeoutIntervalForResource: TimeInterval = defaultTimeoutIntervalForResource,
        cacheEnabled: Bool = true
    ) -> URLSession {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = waitsForConnectivity
        if cacheEnabled {
            config.timeoutIntervalForResource = timeoutIntervalForResource
            let cache = URLCache(
                memoryCapacity: 20 * 1024 * 1024,
                diskCapacity: 100 * 1024 * 1024,
                diskPath: "URLSession.defaultWithConfig"
            )
            config.urlCache = cache
            config.requestCachePolicy = .returnCacheDataElseLoad
        } else {
            config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        }

        return URLSession(configuration: config)
    }
}
