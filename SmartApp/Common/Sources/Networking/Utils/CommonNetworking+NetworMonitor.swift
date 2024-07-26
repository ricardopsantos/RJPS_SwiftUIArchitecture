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

public extension CommonNetworking.NetworkMonitorViewModel {
    enum Status: Equatable, Hashable {
        case unknown
        case internetConnectionAvailable // The first time the connection is available
        case internetConnectionRecovered // When the connection is recovered (after lost)
        case internetConnectionLost // When the connection is lost

        public var existsInternetConnection: Bool {
            switch self {
            case .internetConnectionRecovered, .internetConnectionAvailable:
                true
            case .internetConnectionLost, .unknown:
                false
            }
        }

        var debugMessage: String {
            switch self {
            case .internetConnectionRecovered: "Internet connection active (recovered)"
            case .internetConnectionAvailable: "Internet connection active"
            case .internetConnectionLost: "Internet connection lost (not active)"
            case .unknown: "Unknown"
            }
        }
    }
}

public extension CommonNetworking {
    final class NetworkMonitorViewModel: ObservableObject {
        private init() {
            self.internetConnectionIsAvailable = Common_Utils.existsInternetConnection
            Self.networkMonitor.monitor.pathUpdateHandler = { [weak self] path in
                let existsInternetV1 = path.status == .satisfied
                let existsInternetV2 = Common_Utils.existsInternetConnection
                self?.internetConnectionIsAvailable = existsInternetV1 && existsInternetV2
            }
        }

        private static var networkMonitor = CommonNetworking.NetworkMonitor.shared
        public static var shared = NetworkMonitorViewModel()
        @Published public private(set) var status: CommonNetworking.NetworkMonitorViewModel.Status = .unknown

        private var internetConnectionIsAvailable: Bool? {
            didSet {
                guard let newValue = internetConnectionIsAvailable else {
                    return
                }
                Common_Utils.executeInMainTread { [weak self] in
                    guard let self else { return }
                    if newValue {
                        if status == .unknown {
                            status = .internetConnectionAvailable
                        } else {
                            status = .internetConnectionRecovered
                        }
                    } else {
                        status = .internetConnectionLost
                    }
                }
            }
        }
    }
}

public extension CommonNetworking {
    class NetworkMonitor {
        public typealias Status = CommonNetworking.NetworkMonitorViewModel.Status
        public static var shared = CommonNetworking.NetworkMonitor()
        private init() {
            self.monitor = NWPathMonitor()
            monitor.start(queue: DispatchQueue(label: "\(Self.self).queue", qos: .userInitiated))
        }

        fileprivate var monitor: NWPathMonitor!
        @PWThreadSafe fileprivate var statusHistory: [Status] = []
        fileprivate var currentStatus: Status {
            if let last = statusHistory.last {
                return last
            }
            return .unknown
        }

        public func start(
            onAvailable: @escaping (Status) -> Void,
            onRecovered: @escaping (Status) -> Void,
            onLost: @escaping (Status) -> Void
        ) {
            Self.shared.monitor.pathUpdateHandler = { [weak self] path in
                guard let self else { return }
                let existsInternetV1 = path.status == .satisfied
                let existsInternetV2 = Common_Utils.existsInternetConnection
                let existsInternet = existsInternetV1 && existsInternetV2
                // Common.LogsManager.debug("existsInternetV1: \(existsInternetV1), existsInternetV2: \(existsInternetV2)")

                weak var weakSelf = self
                func finishWith(status: CommonNetworking.NetworkMonitorViewModel.Status) {
                    guard weakSelf != nil else {
                        return
                    }
                    // guard let self = self else { return }
                    guard status != self.currentStatus else {
                        // Ignore duplicated
                        return
                    }
                    self.statusHistory.append(status)
                    Common.LogsManager.debug(status.debugMessage)
                    switch status {
                    case .unknown: ()
                    case .internetConnectionAvailable: onAvailable(status)
                    case .internetConnectionRecovered: onRecovered(status)
                    case .internetConnectionLost: onLost(status)
                    }
                    onAvailable(status)
                }

                if currentStatus.existsInternetConnection != existsInternet {
                    if existsInternet {
                        if currentStatus == .unknown {
                            // The app started with internet!
                            finishWith(status: .internetConnectionAvailable)
                        } else {
                            // The app recovered from internet loss!
                            finishWith(status: .internetConnectionRecovered)
                        }
                    } else {
                        // The app don't have internet
                        finishWith(status: .internetConnectionLost)
                    }
                } else if !existsInternet {
                    // The app started without internet!
                    finishWith(status: .internetConnectionLost)
                }

                // Sometimes, after we recovered/lost internet, we still have the value for
                // `existsInternet` wrong. So after 1s, we always recheck
                Common_Utils.delay(1) {
                    if Common_Utils.existsInternetConnection != existsInternet {
                        if Common_Utils.existsInternetConnection {
                            finishWith(status: .internetConnectionRecovered)
                        } else {
                            finishWith(status: .internetConnectionLost)
                        }
                    }
                }
            }
        }
    }
}
