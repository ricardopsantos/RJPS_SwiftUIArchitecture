//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Network
import Combine
#if !os(watchOS)
import SystemConfiguration
#endif

// https://www.vadimbulavin.com/network-connectivity-on-ios-with-swift/

public extension CommonNetworking {
    struct Reachability {
        private init() {}

        private static var defaultRouteReachability: SCNetworkReachability? {
            var zeroAddress = sockaddr()
            zeroAddress.sa_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sa_family = sa_family_t(AF_INET)
            return withUnsafePointer(to: &zeroAddress) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        public static var isConnectedToNetwork: Bool {
            if Common_Utils.onSimulator, Common_Utils.false {
                isConnectedToNetworkV3 // Slow! Takes 1s
            } else {
                isConnectedToNetworkV2
            }
        }

        @PWThreadSafe private static var isConnected = false
        @PWThreadSafe private static var isFetching = false
        @PWThreadSafe private static var semaphore = DispatchSemaphore(value: 1)
        @PWThreadSafe private static var lastRequestTime: Date?
        public static var isConnectedToNetworkV3: Bool {
            semaphore.wait()
            defer { semaphore.signal() }

            // Check if less than 1 second has passed since the last request
            if let lastRequestTime, Date().timeIntervalSince(lastRequestTime) < 1 {
                // If less than 1 second, return the result of the last request
                return isConnected
            }

            if isFetching {
                // If a request is already in progress, wait for its completion and return the result
                return isConnected
            } else {
                // Start a new request
                isFetching = true
                lastRequestTime = Date() // Update last request time
                if let request = URL(string: "https://www.google.com") {
                    let task = URLSession.shared.dataTask(with: request) { _, response, error in
                        defer {
                            isFetching = false
                        }
                        if error == nil, let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode {
                            isConnected = true
                        } else {
                            isConnected = false
                        }
                    }
                    task.resume()
                    _ = semaphore.wait(timeout: .now() + 1)
                    task.cancel()
                }
                return isConnected
            }
        }

        public static var isConnectedToNetworkV2: Bool {
            guard let defaultRouteReachability else {
                return false
            }
            var flags = SCNetworkReachabilityFlags()
            if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                let isReachable = flags.contains(.reachable)
                let needsConnection = flags.contains(.connectionRequired)
                return isReachable && !needsConnection
            }
            return false
        }

        public static var isConnectedToNetworkV1: Bool {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
                return false
            }
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            return isReachable && !needsConnection
        }
    }
}
