//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2023 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData
import Combine

//
// MARK: - CodableCacheManagerProtocol
//

public class CacheManagerForCodableDBRepository {
    let cancelBag = CancelBag()
    lazy var syncCoreDataManager: CommonCoreDataNameSpace.SyncCoreDataManager = {
        CommonCoreDataNameSpace.CoreDataManager(
            dbName: Common.internalDB,
            dbBundle: Common.bundleIdentifier
        ).syncInstance.manager
    }()
    lazy var asyncCoreDataManager: CommonCoreDataNameSpace.AsyncCoreDataManager = {
        CommonCoreDataNameSpace.CoreDataManager(
            dbName: Common.internalDB,
            dbBundle: Common.bundleIdentifier
        ).aSyncInstance.manager
    }()
    lazy var defaultContext: NSManagedObjectContext = {
        return syncCoreDataManager.mainViewContext
    }()
}

extension CacheManagerForCodableDBRepository: CodableCacheManagerProtocol {
    public func clearAll() {
        requestCacheDelete()
    }

    public func syncRetrieve<T: Codable>(_ some: T.Type, key: String, params: [any Hashable]) -> (model: T, recordDate: Date)? {
        // Faster
        // Test: test_fetchingRecordFrom_1000000Records() -> 0.07s
        let composedKey = Commom_ExpiringCodableObjectWithKey.composedKey(key, params)
        do {
            let context = defaultContext
            let record = try? context
                .fetch(CDataExpiringKeyValueEntity.fetchRequestWith(key: composedKey))
                .compactMap { record in
                    let encoding = Commom_ExpiringCodableObjectWithKey.ValueEncoding(rawValue: Int(record.encoding)) ?? .dataPlain
                    let model = Commom_ExpiringCodableObjectWithKey(
                        key: record.key!,
                        expireDate: record.expireDate!,
                        object: record.object!,
                        objectType: record.objectType!,
                        encoding: encoding
                    )
                    return model
                }
                .sorted(by: { a, b in
                    a.recordDate > b.recordDate
                })
                .first
            if let record = record, let extracted = record.extract(T.self) {
                return (extracted, record.recordDate)
            }
        }

        return nil
    }

    public func syncStore<T: Codable>(_ codable: T, key: String, params: [any Hashable], timeToLiveMinutes: Int?) {
        let toStore = Commom_ExpiringCodableObjectWithKey(
            codable,
            key: key,
            params: params,
            timeToLiveMinutes: timeToLiveMinutes
        )
        guard let key = toStore.key, !key.isEmpty else {
            return
        }
        let newInstance: CDataExpiringKeyValueEntity = syncCoreDataManager.createEntity()
        newInstance.key = toStore.key
        newInstance.recordDate = toStore.recordDate
        newInstance.expireDate = toStore.expireDate
        newInstance.encoding = Int16(toStore.encoding)
        newInstance.object = toStore.object
        newInstance.objectType = toStore.objectType
        syncCoreDataManager.saveContext()
    }
}

public extension CacheManagerForCodableDBRepository {
    //
    // MARK: - Cached Records
    //

    func requestCacheDelete() {
        let request = NSFetchRequest<CDataExpiringKeyValueEntity>(entityName: CDataExpiringKeyValueEntity.entityName)
        asyncCoreDataManager
            .publisher(delete: request)
            .sink { _ in } receiveValue: { _ in
                Common.LogsManager.debug("Deleting \(CDataExpiringKeyValueEntity.entityName) succeeded")
            }
            .store(in: cancelBag)
    }
}
