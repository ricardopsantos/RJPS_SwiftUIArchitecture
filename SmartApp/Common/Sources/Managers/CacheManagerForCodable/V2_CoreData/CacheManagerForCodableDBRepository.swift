//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2023 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData
import Combine

public extension Common {
    class CoreDataStack: SyncCoreDataManagerCRUDProtocol {
        public static var shared = CoreDataStack(dbName: Common.internalDB, bundle: Common.bundleIdentifier)
        let cancelBag = CancelBag()
        private let dbName: String
        private let bundle: String

        fileprivate init(dbName: String, bundle: String) {
            self.dbName = dbName
            self.bundle = bundle
        }

        fileprivate lazy var syncCoreDataManager: CommonCoreDataNameSpace.SyncCoreDataManager = {
            CommonCoreDataNameSpace.CoreDataManager(
                dbName: dbName,
                dbBundle: bundle
            ).syncInstance.manager
        }()

        fileprivate lazy var aSyncCoreDataManager: CommonCoreDataNameSpace.AsyncCoreDataManager = {
            CommonCoreDataNameSpace.CoreDataManager(
                dbName: dbName,
                dbBundle: bundle
            ).aSyncInstance.manager
        }()

        public lazy var viewContext: NSManagedObjectContext = {
            syncCoreDataManager.mainViewContext
        }()

        public lazy var mainViewContext: NSManagedObjectContext = {
            syncCoreDataManager.mainViewContext
        }()

        public lazy var privateViewContext: NSManagedObjectContext = {
            syncCoreDataManager.privateViewContext
        }()

        func reset() {
            mainViewContext.reset()
            privateViewContext.reset()
        }

        func saveMainContext() {
            CommonCoreDataNameSpace.Utils.save(viewContext: mainViewContext)
        }

        @discardableResult
        func saveContext(ctx: Weak<NSManagedObjectContext>) -> Bool {
            guard let ctx = ctx.value, ctx.hasChanges else {
                return false
            }
            return CommonCoreDataNameSpace.Utils.save(viewContext: ctx)
        }
    }
}

//
// MARK: - CodableCacheManagerProtocol
//
extension Common.CoreDataStack: CodableCacheManagerProtocol {
    public func clearAll() {
        requestCacheDelete()
    }

    public func aSyncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) async -> (model: T, recordDate: Date)? {
        try? await withCheckedThrowingContinuation { continuation in
            let result = syncRetrieve(type, key: key, params: params)
            continuation.resume(with: .success(result))
        }
    }

    public func syncRetrieve<T: Codable>(_ some: T.Type, key: String, params: [any Hashable]) -> (model: T, recordDate: Date)? {
        // Faster
        // Test: test_fetchingRecordFrom_1000000Records() -> 0.07s
        let composedKey = Commom_ExpiringCodableObjectWithKey.composedKey(key, params)
        do {
            print(Thread.isMainThread)
            let context = Thread.isMainThread ? syncCoreDataManager.mainViewContext : aSyncCoreDataManager.privateViewContext
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

    public func syncStore<T: Codable>(
        _ codable: T,
        key: String,
        params: [any Hashable],
        timeToLiveMinutes: Int? = nil
    ) {
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

public extension Common.CoreDataStack {
    //
    // MARK: - Cached Records
    //

    func requestCacheDelete() {
        let request = NSFetchRequest<CDataExpiringKeyValueEntity>(entityName: CDataExpiringKeyValueEntity.entityName)
        aSyncCoreDataManager
            .publisher(delete: request)
            .sink { _ in } receiveValue: { _ in
                Common.LogsManager.debug("Deleting \(CDataExpiringKeyValueEntity.entityName) succeeded")
            }
            .store(in: cancelBag)
    }
}
