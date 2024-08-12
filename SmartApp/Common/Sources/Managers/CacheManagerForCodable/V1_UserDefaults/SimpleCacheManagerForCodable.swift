//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

//
// MARK: - CacheManagerForCodableUserDefaultsRepository
//

public extension Common {
    class CacheManagerForCodableUserDefaultsRepository: CodableCacheManagerProtocol {
        private init() {}
        public static let shared = CacheManagerForCodableUserDefaultsRepository()
        private lazy var userDefaults: UserDefaults = {
            .init(suiteName: "\(CacheManagerForCodableUserDefaultsRepository.self)") ?? .standard
        }()

        //
        // MARK: - Sync
        //
        public func syncStore(
            _ codable: some Codable,
            key: String,
            params: [any Hashable],
            timeToLiveMinutes: Int? = nil
        ) {
            let expiringCodableObjectWithKey = Commom_ExpiringKeyValueEntity(
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
            guard let data = userDefaults.data(forKey: Commom_ExpiringKeyValueEntity.composedKey(key, params)),
                  let expiringCodableObjectWithKey = try? JSONDecoder().decodeFriendly(Common.ExpiringKeyValueEntity.self, from: data),
                  let cachedRecord = expiringCodableObjectWithKey.extract(type) else {
                return nil
            }
            return (cachedRecord, expiringCodableObjectWithKey.recordDate)
        }

        public func syncAllCachedKeys() -> [(String, Date)] {
            let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(Common.ExpiringKeyValueEntity.composedKeyPrefix) }
            var result: [(String, Date)] = []
            keys.forEach { key in
                if let data = userDefaults.data(forKey: key) {
                    if let expiringCodableObjectWithKey = try? JSONDecoder().decodeFriendly(Common.ExpiringKeyValueEntity.self, from: data) {
                        result.append((key, expiringCodableObjectWithKey.recordDate))
                    }
                }
            }
            return result
        }

        public func syncClearAll() {
            let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(Common.ExpiringKeyValueEntity.composedKeyPrefix) }
            for key in keys {
                userDefaults.set(nil, forKey: key)
                //userDefaults.removeObject(forKey: key)
                userDefaults.synchronize()
            }
 //           userDefaults.synchronize()
        }

        //
        // MARK: - Async
        //
        public func aSyncStore<T: Codable>(_ codable: T, key: String, params: [any Hashable], timeToLiveMinutes: Int?) async {
            try? await withCheckedThrowingContinuation { continuation in
                syncStore(codable, key: key, params: params, timeToLiveMinutes: timeToLiveMinutes)
                continuation.resume()
            }
        }

        public func aSyncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) async -> (model: T, recordDate: Date)? {
            try? await withCheckedThrowingContinuation { continuation in
                let result = syncRetrieve(type, key: key, params: params)
                continuation.resume(with: .success(result))
            }
        }

        public func aSyncClearAll() async {
            try? await withCheckedThrowingContinuation { continuation in
                syncClearAll()
                continuation.resume()
            }
        }

        public func aSyncAllCachedKeys() async -> [(String, Date)] {
            do {
                return try await withCheckedThrowingContinuation { continuation in
                    let result = syncAllCachedKeys()
                    continuation.resume(with: .success(result))
                }
            } catch {}
            return []
        }
    }
}

//
// MARK: Sample Usage
//
public extension Common.CacheManagerForCodableUserDefaultsRepository {
    typealias ResponseCachedRequest = AnyPublisher<
        NetworkAgentSampleNamespace.ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    static func sampleUsage() -> ResponseCachedRequest {
        NetworkAgentSampleNamespace.cachedRequest(cachePolicy: .cacheAndLoad)
    }
}
