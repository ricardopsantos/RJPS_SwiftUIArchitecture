//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

//
// MARK: - SimpleCacheManagerForCodable
//

public extension Common {
    class SimpleCacheManagerForCodable: CodableCacheManagerProtocol {
        private init() {}
        public static let shared = SimpleCacheManagerForCodable()
        private lazy var userDefaults: UserDefaults = {
            .init(suiteName: "\(SimpleCacheManagerForCodable.self)") ?? .standard
        }()

        public func syncStore(
            _ codable: some Codable,
            key: String,
            params: [any Hashable],
            timeToLiveMinutes: Int? = nil
        ) {
            let expiringCodableObjectWithKey = Commom_ExpiringCodableObjectWithKey(
                codable,
                key: key,
                params: params,
                timeToLiveMinutes: timeToLiveMinutes
            )
            if let data = try? JSONEncoder().encode(expiringCodableObjectWithKey) {
                userDefaults.set(
                    data,
                    forKey: expiringCodableObjectWithKey.key
                )
                userDefaults.synchronize()
            } else {
                Common_Utils.assert(false, message: "Not predicted")
            }
        }

        public func syncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) -> (model: T, recordDate: Date)? {
            guard let data = userDefaults.data(forKey: Commom_ExpiringCodableObjectWithKey.composedKey(key, params)),
                  let expiringCodableObjectWithKey = try? JSONDecoder().decodeFriendly(Common.ExpiringCodableObjectWithKey.self, from: data),
                  let cachedRecord = expiringCodableObjectWithKey.extract(type) else {
                return nil
            }
            return (cachedRecord, expiringCodableObjectWithKey.recordDate)
        }

        public func clearAll() {
            let allKeys = userDefaults.dictionaryRepresentation().keys
            let keysToDelete = allKeys.filter { $0.hasPrefix(Common.ExpiringCodableObjectWithKey.composedKeyPrefix) }
            for key in keysToDelete {
                userDefaults.removeObject(forKey: key)
            }
            userDefaults.synchronize()
        }
    }
}

//
// MARK: Sample Usage
//
public extension Common.SimpleCacheManagerForCodable {
    
    typealias ResponseCachedRequest = AnyPublisher<NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability,
                                                   CommonNetworking.APIError>
    static func sampleUsage() -> ResponseCachedRequest {
        NetworkAgentSampleNamespace.cachedRequest(cachePolicy: .cacheAndLoad)
    }
}
