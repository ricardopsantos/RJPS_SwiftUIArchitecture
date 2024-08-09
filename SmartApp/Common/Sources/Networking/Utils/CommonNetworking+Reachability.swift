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
        
        private static var defaultReachability: SCNetworkReachability? {
            var zeroAddress = sockaddr()
            zeroAddress.sa_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sa_family = sa_family_t(AF_INET)
            return withUnsafePointer(to: &zeroAddress) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        /**
         V1 and V2 are quick and simple, suitable for cases where you just need to check local network availability.
         V3 offers more accurate detection of actual internet connectivity but at the cost of increased complexity and potential latency.
         It’s better suited for scenarios where knowing if the internet is genuinely accessible is critical.
         */
        public enum Method: Int {
            case v1 //
            case v2
            case v3
            
            public static var `default`: Self {
                .v2
            }
        }
        
        public static func isConnectedToNetwork(_ method: CommonNetworking.Reachability.Method) -> Bool {
            switch method {
            case .v1: return isConnectedToNetworkV1
            case .v2: return isConnectedToNetworkV2
            case .v3: return isConnectedToNetworkV3
            }
        }

        /// Basic Synchronous Reachability Check
        /// is better if you need more control over network reachability checks, such as if you need to work with specific network configurations or addresses.
        private static var isConnectedToNetworkV1: Bool {
            // Initialize a sockaddr_in structure to represent a zeroed-out address.
            var zeroAddress = sockaddr_in()
            // Set the length of the sockaddr_in structure to its size in bytes.
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            // Set the address family to AF_INET (IPv4).
            zeroAddress.sin_family = sa_family_t(AF_INET)
            // Create a network reachability reference using the zeroed-out address.
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            // Initialize an empty SCNetworkReachabilityFlags structure to hold the reachability flags.
            var flags = SCNetworkReachabilityFlags()
            // Check if the network reachability flags can be retrieved from the default route reachability reference.
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
                // If the flags cannot be retrieved, return false indicating no network connection.
                return false
            }
            // Check if the network is reachable by examining the kSCNetworkFlagsReachable flag.
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            // Check if a connection is required by examining the kSCNetworkFlagsConnectionRequired flag.
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            // Return true if the network is reachable and no connection is required, otherwise return false.
            return isReachable && !needsConnection
        }

        /// Improved Synchronous Reachability Check
        /// is better for most cases, particularly if simplicity, readability, and maintainability are your priorities.
        private static var isConnectedToNetworkV2: Bool {
            // Ensure that the defaultReachability is not nil. If it is nil, return false.
            guard let defaultReachability else {
                return false
            }
            // Create an empty SCNetworkReachabilityFlags structure to hold the network reachability flags.
            var flags = SCNetworkReachabilityFlags()
            // Check if the network reachability flags can be retrieved from defaultReachability.
            if SCNetworkReachabilityGetFlags(defaultReachability, &flags) {
                // Check if the network is reachable.
                let isReachable = flags.contains(.reachable)
                // Check if a connection is required to reach the network.
                let needsConnection = flags.contains(.connectionRequired)
                // Return true if the network is reachable and no additional connection is required.
                return isReachable && !needsConnection
            }
            // Return false if the network reachability flags could not be retrieved.
            return false
        }


        @PWThreadSafe private static var isConnected = false
        @PWThreadSafe private static var isFetching = false
        @PWThreadSafe private static var semaphore = DispatchSemaphore(value: 1)
        @PWThreadSafe private static var lastRequestTime: Date?
        /// Asynchronous Network Request with Caching
        /// offers more accurate detection of actual internet connectivity but at the cost of increased complexity
        /// and potential latency. It’s better suited for scenarios where knowing if the internet is genuinely accessible is critical
        private static var isConnectedToNetworkV3: Bool {
            // Acquire the semaphore to ensure thread-safe access to the network status check
            semaphore.wait()
            
            // Ensure the semaphore is released regardless of how the function exits
            defer { semaphore.signal() }

            // Check if less than 1 second has passed since the last network request
            if let lastRequestTime, Date().timeIntervalSince(lastRequestTime) < 1 {
                // If less than 1 second, return the cached result of the last request
                return isConnected
            }

            // If a network request is currently in progress, return the current connection status
            if isFetching {
                return isConnected
            } else {
                // Start a new network request
                isFetching = true
                lastRequestTime = Date() // Update the last request time
                // Create a URL request to check network connectivity
                if let request = URL(string: "https://www.google.com") {
                    let task = URLSession.shared.dataTask(with: request) { _, response, error in
                        defer {
                            // Mark the request as complete
                            isFetching = false
                        }
                        // Check if the request was successful and the response is within the 200-299 range
                        if error == nil, let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode {
                            isConnected = true
                        } else {
                            isConnected = false
                        }
                    }
                    task.resume()
                    // Wait up to 1 second for the network request to complete
                    _ = semaphore.wait(timeout: .now() + 1)
                    // Cancel the task if it hasn't completed within the timeout period
                    task.cancel()
                }
                // Return the result of the network request
                return isConnected
            }
        }

    }
}
