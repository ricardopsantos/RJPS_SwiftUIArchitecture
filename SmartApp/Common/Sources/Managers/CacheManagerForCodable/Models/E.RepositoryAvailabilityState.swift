//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

public extension Common {
    enum RepositoryAvailabilityState {
        // Enumeration representing the availability states of the repository
        case free // API call queue is free
        case refreshing // API call queue is performing

        // Dictionary to store the availability states for each service key
        internal static var serviceStates: [String: CurrentValueSubject<RepositoryAvailabilityState, Never>] = [:]

        // Lock to synchronize access to the serviceStates dictionary
        private static let lock = NSLock()

        // Locks the service state for the given service key to 'refreshing'
        public static func lockForServiceKey(_ serviceKey: String) {
            synced(lock) {
                if Common_AvailabilityState.serviceStates[serviceKey] == nil {
                    // If the service key doesn't exist, create a new entry with the state set to 'refreshing'
                    Common_AvailabilityState.serviceStates[serviceKey] = .init(.refreshing)
                } else {
                    // If the service key exists, update its state to 'refreshing'
                    Common_AvailabilityState.serviceStates[serviceKey]!.value = .refreshing
                }
            }
        }

        // Unlocks the service state for the given service key, setting it to 'free'
        public static func unLockForServiceKey(_ serviceKey: String) {
            synced(lock) {
                if Common_AvailabilityState.serviceStates[serviceKey] == nil {
                    // If the service key doesn't exist, create a new entry with the state set to 'free'
                    Common_AvailabilityState.serviceStates[serviceKey] = .init(.free)
                } else {
                    // If the service key exists, update its state to 'free'
                    Common_AvailabilityState.serviceStates[serviceKey]!.value = .free
                }
            }
        }
    }
}
