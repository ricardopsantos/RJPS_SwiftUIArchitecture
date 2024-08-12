//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2023 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData
import Combine

public extension Common {
    class CoreDataStack {
        fileprivate let cancelBag = CancelBag()
        private let managedObjectModel: NSManagedObjectModel!
        private let persistentContainer: NSPersistentContainer!
        public static var shared = CoreDataStack(
            dbName: Common.internalDB,
            dbBundle: Common.bundleIdentifier
        )

        public init(dbName: String, dbBundle: String) {
            let nsManagedObjectModel = CommonCoreDataNameSpace.Utils.managedObjectModelWith(
                dbName: dbName,
                dbBundle: dbBundle
            )!
            self.managedObjectModel = nsManagedObjectModel
            self.persistentContainer = CommonCoreDataNameSpace.Utils.storeContainer(
                dbName: dbName,
                managedObjectModel: nsManagedObjectModel,
                storeInMemory: false
            )
        }

        var viewContext: NSManagedObjectContext {
            let context = persistentContainer.viewContext
            context.automaticallyMergesChangesFromParent = true
            return context
        }

        var backgroundContext: NSManagedObjectContext {
            let context = persistentContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            return context
        }
    }
}

//
// MARK: - CodableCacheManagerProtocol
//
extension Common.CoreDataStack: CodableCacheManagerProtocol {
    //
    // MARK: - Sync
    //

    public func syncRetrieve<T: Codable>(_ some: T.Type, key: String, params: [any Hashable]) -> (model: T, recordDate: Date)? {
        // Faster
        // Test: test_fetchingRecordFrom_1000000Records() -> 0.07s
        let composedKey = Commom_ExpiringKeyValueEntity.composedKey(key, params)
        do {
            let context = viewContext
            let record = try? context
                .fetch(CDataExpiringKeyValueEntity.fetchRequestWith(key: composedKey))
                .compactMap(\.asExpiringKeyValueEntity)
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
        let toStore = Commom_ExpiringKeyValueEntity(
            codable,
            key: key,
            params: params,
            timeToLiveMinutes: timeToLiveMinutes
        )
        guard let key = toStore.key, !key.isEmpty else {
            return
        }
        let newInstance: CDataExpiringKeyValueEntity = CDataExpiringKeyValueEntity(context: viewContext)
        newInstance.key = toStore.key
        newInstance.recordDate = toStore.recordDate
        newInstance.expireDate = toStore.expireDate
        newInstance.encoding = Int16(toStore.encoding)
        newInstance.object = toStore.object
        newInstance.objectType = toStore.objectType
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }

    public func syncClearAll() {
        let context = viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDataExpiringKeyValueEntity.fetchRequest()
        let recordCount = try? context.count(for: fetchRequest)
        guard recordCount ?? 0 > 0 else {
            return
        }
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch {
            Common_Logs.error("Failed to delete \(CDataExpiringKeyValueEntity.self) records: \(error.localizedDescription)")
            context.rollback()
        }
    }
    
    public func aSyncClearAll() async {
        await withCheckedContinuation { continuation in
            // Use the background context to perform the delete operation
            let context = backgroundContext
            context.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDataExpiringKeyValueEntity.fetchRequest()
                let recordCount = try? context.count(for: fetchRequest)
                guard recordCount ?? 0 > 0 else {
                    continuation.resume()
                    return
                }
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try context.execute(batchDeleteRequest)
                    try context.save()
                    try context.parent?.save()
                    continuation.resume()
                } catch {
                    Common_Logs.error("Failed to delete \(CDataExpiringKeyValueEntity.self) records: \(error.localizedDescription)")
                    context.rollback()
                    continuation.resume()
                }
            }
        }

    }

    //
    // MARK: - Async
    //
    public func aSyncRetrieve<T: Codable>(_ type: T.Type, key: String, params: [any Hashable]) async -> (model: T, recordDate: Date)? {
        await withCheckedContinuation { continuation in
            // Perform the fetch operation asynchronously on the viewContext
            viewContext.perform {
                do {
                    let composedKey = Commom_ExpiringKeyValueEntity.composedKey(key, params)
                    let records = try self.viewContext
                        .fetch(CDataExpiringKeyValueEntity.fetchRequestWith(key: composedKey))
                        .compactMap(\.asExpiringKeyValueEntity)
                        .sorted(by: { a, b in
                            a.recordDate > b.recordDate
                        })

                    // Get the first record, if it exists
                    if let record = records.first, let extracted = record.extract(T.self) {
                        // Return the model and the record date
                        continuation.resume(returning: (extracted, record.recordDate))
                        return
                    }

                    // If no record was found, return nil
                    continuation.resume(returning: nil)
                } catch {
                    // Handle any errors and return nil
                    Common_Logs.error("Failed to fetch records: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    public func aSyncStore<T: Codable>(
        _ codable: T,
        key: String,
        params: [any Hashable],
        timeToLiveMinutes: Int? = nil
    ) async {
        let toStore = Commom_ExpiringKeyValueEntity(
            codable,
            key: key,
            params: params,
            timeToLiveMinutes: timeToLiveMinutes
        )

        // Check if the key is valid
        guard let key = toStore.key, !key.isEmpty else {
            Common_Logs.error("Invalid key provided for storage.")
            return
        }

        // Use a background context to perform the save operation asynchronously
        let context = backgroundContext
        await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
      
                    // Create a new instance of the entity
                    let newInstance = CDataExpiringKeyValueEntity(context: context)
                    newInstance.key = toStore.key
                    newInstance.recordDate = toStore.recordDate
                    newInstance.expireDate = toStore.expireDate
                    newInstance.encoding = Int16(toStore.encoding)
                    newInstance.object = toStore.object
                    newInstance.objectType = toStore.objectType

                    if context.hasChanges {
                        do {
                            try context.save()
                            try context.parent?.save()
                        } catch {
                            Common_Logs.error("Failed to save changes in viewContext: \(error.localizedDescription)")
                        }
                    }
                
                    // Notify that the save operation is complete
                    continuation.resume()
                
            }
        }
    }



    //
    // MARK: - Utils
    //

    public var codableCacheManager_allCachedKeys: [(String, Date)] {
        fatalError()
        /*
         let manager = syncInstance
         if Thread.isMainThread {
             let fetchRequest: NSFetchRequest<CDataExpiringKeyValueEntity> = CDataExpiringKeyValueEntity.fetchRequest()
             do {
                 let records = try manager.mainViewContext.fetch(fetchRequest)
                 return records.compactMap { ($0.key!, $0.recordDate!) }.sorted(by: { $0.0 > $1.0 })
             } catch {
                 return []
             }
         } else {
             var keys: [(String, Date)] = []
             // let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
             // privateContext.parent = manager.mainViewContext
             let privateContext = manager.privateViewContext
             privateContext.performAndWait {
                 let fetchRequest: NSFetchRequest<CDataExpiringKeyValueEntity> = CDataExpiringKeyValueEntity.fetchRequest()
                 do {
                     let records = try privateContext.fetch(fetchRequest)
                     keys = records.compactMap { ($0.key!, $0.recordDate!) }
                 } catch {}
             }
             return keys.sorted(by: { $0.0 > $1.0 })
         }*/
    }
}

//
// MARK: - Mappers
//

public extension CDataExpiringKeyValueEntity {
    var asExpiringKeyValueEntity: Commom_ExpiringKeyValueEntity? {
        let encoding = Commom_ExpiringKeyValueEntity.ValueEncoding(rawValue: Int(encoding)) ?? .dataPlain
        return Commom_ExpiringKeyValueEntity(
            key: key!,
            expireDate: expireDate!,
            object: object!,
            objectType: objectType!,
            encoding: encoding
        )
    }
}
