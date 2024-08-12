//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

internal typealias Common_AvailabilityState = Common.RepositoryAvailabilityState
public typealias Common_GenericRequestWithCacheResponse<T1: Codable, E1: Error> = AnyPublisher<T1, E1>

extension String: Error {}

public extension Common {
    struct GenericRequestWithCodableCache {
        private init() {}

        public enum OnCachedRecordNotFound: Error {
            case returnEmpty
            case returnError
        }

        public static func perform<T1: Codable, E1: Error>(
            _ publisher: @autoclosure () -> AnyPublisher<some Codable, some Error>,
            _ type: T1.Type,
            _ cachePolicy: Common.CachePolicy,
            _ serviceKey: String,
            _ serviceParams: [any Hashable],
            _ timeToLiveMinutes: Int? = nil,
            _ cacheManager: CodableCacheManagerProtocol = Common_SimpleCacheManagerForCodable.shared,
            _ onCachedRecordNotFound: OnCachedRecordNotFound = .returnEmpty) -> Common_GenericRequestWithCacheResponse<T1, E1> {
            let lock = {
                Common_AvailabilityState.lockForServiceKey(serviceKey)
            }

            let unlock = {
                Common_AvailabilityState.unLockForServiceKey(serviceKey)
            }

            var existsCachedRecord: Bool {
                cacheManager.syncRetrieve(type, key: serviceKey, params: serviceParams)?.model != nil
            }

            // Fetch for CACHED data
            func cacheDontLoad() -> Common_GenericRequestWithCacheResponse<T1, E1> {
                if let storedModel = cacheManager.syncRetrieve(
                    type,
                    key: serviceKey,
                    params: serviceParams) {
                    // Found cache
                    return Just(storedModel.model).setFailureType(to: E1.self).eraseToAnyPublisher()
                } else {
                    // Didn't found cache
                    switch onCachedRecordNotFound {
                    case .returnEmpty:
                        return .empty()
                    case .returnError:
                        let error = NSError(domain: "com.example.error", code: 0, userInfo: ["message": "No cached value"])
                        return Fail(error: error as! E1).eraseToAnyPublisher()
                    }
                }
            }

            // Fetch for NEW data
            func noCacheDoLoad() -> Common_GenericRequestWithCacheResponse<T1, E1> {
                lock()
                return publisher().onErrorCompleteV2(withClosure: { unlock() })
                    .flatMap { model -> Common_GenericRequestWithCacheResponse<T1, E1> in
                        defer {
                            unlock()
                        }
                        cacheManager.syncStore(
                            model,
                            key: serviceKey,
                            params: serviceParams,
                            timeToLiveMinutes: timeToLiveMinutes)
                        if let model = model as? T1 {
                            return Just(model).setFailureType(to: E1.self).eraseToAnyPublisher()
                        } else {
                            Common_Utils.assert(false, message: "Not predicted!")
                            switch onCachedRecordNotFound {
                            case .returnEmpty:
                                return .empty()
                            case .returnError:
                                let error = NSError(domain: "com.example.error", code: 0, userInfo: ["message": "No cached value"])
                                return Fail(error: error as! E1).eraseToAnyPublisher()
                            }
                        }
                    }
                    .catch { error -> Common_GenericRequestWithCacheResponse<T1, E1> in
                        defer {
                            unlock()
                        }
                        return Fail(error: error).eraseToAnyPublisher()
                    }.eraseToAnyPublisher()
            }

            // Fetch for NEW data, OR wait for cache data to change and
            func noCacheDoLoadOrWait() -> Common_GenericRequestWithCacheResponse<T1, E1> {
                switch Common_AvailabilityState.serviceStates[serviceKey]?.value ?? .free {
                case .free: noCacheDoLoad()
                case .refreshing: awaitForCache()
                }
            }

            // Theres already a request on the way. Lets wait for it to end and then return the cached value
            func awaitForCache() -> Common_GenericRequestWithCacheResponse<T1, E1> {
                Common_AvailabilityState.serviceStates[serviceKey]!
                    .filter { $0 == .free }
                    .flatMap { _ in cacheDontLoad()
                    }.eraseToAnyPublisher()
            }

            switch cachePolicy {
            case .ignoringCache:
                return noCacheDoLoadOrWait()
            case .cacheElseLoad:
                if existsCachedRecord {
                    return cacheDontLoad()
                }
                return noCacheDoLoadOrWait()
            case .cacheAndLoad:
                let cacheDontLoad = cacheDontLoad().onErrorCompleteV2()
                    .setFailureType(to: E1.self).eraseToAnyPublisher()
                return Publishers.Merge(cacheDontLoad, noCacheDoLoadOrWait()).eraseToAnyPublisher()
            case .cacheDontLoad:
                return cacheDontLoad()
            }
        }
    }
}
