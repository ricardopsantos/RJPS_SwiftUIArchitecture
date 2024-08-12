//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

public typealias Common_SimpleCacheManagerForCodable = Common.CacheManagerForCodableUserDefaultsRepository
public typealias Commom_ExpiringKeyValueEntity = Common.ExpiringKeyValueEntity

//
// MARK: - CodableCacheManagerProtocol
//

public protocol CodableCacheManagerProtocol {
    //
    // MARK: - Sync
    //
    func syncStore<T: Codable>(_ codable: T, key: String, params: [any Hashable], timeToLiveMinutes: Int?)
    func syncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) -> (model: T, recordDate: Date)?
    func syncClearAll()

    //
    // MARK: - Async
    //
    func aSyncStore<T: Codable>(_ codable: T, key: String, params: [any Hashable], timeToLiveMinutes: Int?) async
    func aSyncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) async -> (model: T, recordDate: Date)?
    func aSyncClearAll() async

    //
    // MARK: - Utils
    //
    var codableCacheManager_allCachedKeys: [(String, Date)] { get }
}
