//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

public typealias Common_SimpleCacheManagerForCodable = Common.CacheManagerForCodableUserDefaultsRepository
public typealias Commom_ExpiringCodableObjectWithKey = Common.ExpiringCodableObjectWithKey

//
// MARK: - CodableCacheManagerProtocol
//

public protocol CodableCacheManagerProtocol {
    func syncStore<T: Codable>(_ codable: T, key: String, params: [any Hashable], timeToLiveMinutes: Int?)
    func syncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) -> (model: T, recordDate: Date)?
    func aSyncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) async -> (model: T, recordDate: Date)?
    func clearAll()
}
