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
    enum NetworkStatus: Equatable, Hashable, Sendable {
        case unknown
        case internetConnectionAvailable
        case internetConnectionRecovered
        case internetConnectionLost

        public var existsInternetConnection: Bool {
            switch self {
            case .internetConnectionAvailable, .internetConnectionRecovered:
                return true
            case .unknown, .internetConnectionLost:
                return false
            }
        }
    }

    @MainActor
    final class NetworkMonitorViewModel: ObservableObject {
        private static let networkMonitor = NetworkMonitor.shared
        public static let shared = NetworkMonitorViewModel()

        @Published public private(set) var networkStatus: NetworkStatus = .unknown

        private init() {
            self.networkStatus = Common_Utils.existsInternetConnection ? .internetConnectionAvailable : .internetConnectionLost
            Self.networkMonitor.start { [weak self] newStatus in
                self?.networkStatus = newStatus
            }
        }
    }

    final class NetworkMonitor {
        public typealias Status = NetworkStatus
        public static let shared = NetworkMonitor()

        private var monitor: NWPathMonitor!
        private var isInternetConnectionAvailable: Bool?
        private var statusHistory = [Status]()

        private init() {
            self.monitor = NWPathMonitor()
            monitor.start(queue: DispatchQueue(label: "\(Self.self).queue", qos: .userInitiated))
        }

        public func start(statusUpdate: @escaping (Status) -> Void) {
            monitor.pathUpdateHandler = { [weak self] path in
                Common_Utils.executeInMainTread { [weak self] in
                    guard let self = self else { return }
                    let newStatusV1: Status
                    if Common_Utils.existsInternetConnection {
                        if self.isInternetConnectionAvailable == nil {
                            newStatusV1 = .internetConnectionAvailable
                        } else {
                            newStatusV1 = .internetConnectionRecovered
                        }
                    } else {
                        newStatusV1 = .internetConnectionLost
                    }

                    let newStatusV2: Status
                    if path.status == .satisfied {
                        if self.isInternetConnectionAvailable == nil {
                            newStatusV2 = .internetConnectionAvailable
                        } else {
                            newStatusV2 = .internetConnectionRecovered
                        }
                    } else {
                        newStatusV2 = .internetConnectionLost
                    }

                    let newStatus = newStatusV2
                    if self.statusHistory.last != newStatus {
                        self.statusHistory.append(newStatus)
                        statusUpdate(newStatus)
                        self.isInternetConnectionAvailable = newStatus.existsInternetConnection
                    }
                }
            }
        }
    }
}
