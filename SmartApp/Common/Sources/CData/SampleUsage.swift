//
//  SampleUsage.swift
//  Common
//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation
import CoreData

public extension CommonCoreData.Utils {
    struct Sample {}
}

//
// MARK: - CRUDEntity
//

public extension CommonCoreData.Utils.Sample {
    struct CRUDEntity: Equatable {
        public let id: String
        public let name: String
        public let recordDate: Date
        public init(id: String, name: String, recordDate: Date) {
            self.id = id
            self.name = name
            self.recordDate = recordDate
        }

        static var random: Self {
            CRUDEntity(
                id: UUID().uuidString,
                name: "Joe \(String.randomWithSpaces(10))",
                recordDate: Date()
            )
        }
    }
}

//
// MARK: - CRUDEntityDBRepository
//
public extension CommonCoreData.Utils.Sample {
    class CRUDEntityDBRepository: CommonCoreData.BaseCoreDataManager {
        public static var shared = CRUDEntityDBRepository(
            dbName: Common.internalDB,
            dbBundle: Common.bundleIdentifier
        )
        override public init(dbName: String, dbBundle: String) {
            super.init(dbName: dbName, dbBundle: dbBundle)
        }
    }
}

//
// MARK: - CRUDEntityDBRepository / Sync Methods
//
extension CommonCoreData.Utils.Sample.CRUDEntityDBRepository {
    func syncStore(_ model: CommonCoreData.Utils.Sample.CRUDEntity) {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        let newInstance: DBEntity = DBEntity(context: context)
        newInstance.id = model.id
        newInstance.name = model.name
        newInstance.recordDate = model.recordDate
        try? context.save()
    }

    func syncRecordCount() -> Int {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        return (try? context.count(for: DBEntity.fetchRequest())) ?? 0
    }

    func syncClearAll() {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        guard syncRecordCount() > 0 else { return }
        CommonCoreData.Utils.delete(context: context, request: DBEntity.fetchRequest())
    }

    func syncRetrieve(key: String) -> CommonCoreData.Utils.Sample.CRUDEntity? {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        do {
            let record = try? context
                .fetch(DBEntity.fetchRequestWith(key: key))
                .compactMap(\.mapToModel)
                .sorted(by: { a, b in
                    a.recordDate > b.recordDate
                })
                .first
            if let record = record {
                return record
            }
        }
        return nil
    }

    public func syncAllIds() -> [String] {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        do {
            let records = try context.fetch(DBEntity.fetchRequest())
            return records.compactMap { $0.id! }
        } catch {
            return []
        }
    }
}

//
// MARK: - CRUDEntityDBRepository / Async Methods
//
extension CommonCoreData.Utils.Sample.CRUDEntityDBRepository {
    func aSyncStore(_ model: CommonCoreData.Utils.Sample.CRUDEntity) async {
        typealias DBEntity = CDataCRUDEntity
        let context = backgroundContext // Use a background context to perform the operation asynchronously
        await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                let newInstance: DBEntity = DBEntity(context: context)
                newInstance.id = model.id
                newInstance.name = model.name
                newInstance.recordDate = model.recordDate
                try? context.save()
                continuation.resume()
            }
        }
    }

    func aSyncRecordCount() async -> Int {
        typealias DBEntity = CDataCRUDEntity
        let context = backgroundContext // Use a background context to perform the operation asynchronously
        return await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                let count = (try? context.count(for: DBEntity.fetchRequest())) ?? 0
                continuation.resume(returning: count)
            }
        }
    }

    func aSyncClearAll() async {
        guard await aSyncRecordCount() > 0 else { return }
        typealias DBEntity = CDataCRUDEntity
        let context = backgroundContext // Use a background context to perform the operation asynchronously
        await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                CommonCoreData.Utils.delete(context: context, request: DBEntity.fetchRequest())
                continuation.resume()
            }
        }
    }

    func aSyncRetrieve(key: String) async -> CommonCoreData.Utils.Sample.CRUDEntity? {
        typealias DBEntity = CDataCRUDEntity
        let context = backgroundContext // Use a background context to perform the operation asynchronously
        return await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                let record = try? context
                    .fetch(DBEntity.fetchRequestWith(key: key))
                    .compactMap(\.mapToModel)
                    .sorted(by: { a, b in
                        a.recordDate > b.recordDate
                    })
                    .first
                continuation.resume(returning: record)
            }
        }
    }

    public func aSyncAllIds() async -> [String] {
        typealias DBEntity = CDataCRUDEntity
        let context = backgroundContext // Use a background context to perform the operation asynchronously
        return await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                var result: [String] = []
                do {
                    let records = try context.fetch(DBEntity.fetchRequest())
                    result = records.compactMap { $0.id! }
                } catch {}
                continuation.resume(returning: result)
            }
        }
    }
}

//
// MARK: - CRUDEntityDBRepository / Sync Methods
//
public extension CommonCoreData.Utils.Sample {
    static func test() {
        testSync()
        Task {
            await testAsync()
        }
    }

    static func testSync() {
        let bd = CommonCoreData.Utils.Sample.CRUDEntityDBRepository.shared

        bd.syncClearAll()
        if bd.syncRecordCount() != 0 {
            fatalError("Should be 0")
        }

        let storedUser: CommonCoreData.Utils.Sample.CRUDEntity = .random
        bd.syncStore(storedUser)
        bd.syncStore(.random)

        if bd.syncRecordCount() != 2 {
            fatalError("Should be 2")
        }

        let ids = bd.syncAllIds()
        if ids.count != 2 {
            fatalError("Should be 2")
        }
        
        if bd.syncRecordCount() != 2 {
            fatalError("Should be 2")
        }
        if let retrieveUser = bd.syncRetrieve(key: storedUser.id) {
            if retrieveUser != storedUser {
                fatalError("Should be equal")
            }
        } else {
            fatalError("Should had found")
        }

        bd.syncClearAll()

        if bd.syncRecordCount() != 0 {
            fatalError("Should be 0")
        }
    }

    static func testAsync() async {
        let bd = CommonCoreData.Utils.Sample.CRUDEntityDBRepository.shared

        await bd.aSyncClearAll()
        if await bd.aSyncRecordCount() != 0 {
            fatalError("Should be 0")
        }
        
        let storedUser: CommonCoreData.Utils.Sample.CRUDEntity = .random
        await bd.aSyncStore(storedUser)
        await bd.aSyncStore(.random)

        if await bd.aSyncRecordCount() != 2 {
            fatalError("Should be 2")
        }
        
        let ids = await bd.aSyncAllIds()
        if ids.count != 2 {
            fatalError("Should be 2")
        }
        
        if let retrieveUser = await bd.aSyncRetrieve(key: storedUser.id) {
            if retrieveUser != storedUser {
                fatalError("Should be equal")
            }
        } else {
            fatalError("Should had found")
        }

        await bd.aSyncClearAll()
        if await bd.aSyncRecordCount() != 0 {
            fatalError("Should be 0")
        }
    }
}

//
// MARK: - CDataCRUDEntity
//

//
// Mappers
//
public extension CDataCRUDEntity {
    var mapToModel: CommonCoreData.Utils.Sample.CRUDEntity? {
        .init(id: id ?? "", name: name ?? "", recordDate: recordDate ?? .now)
    }
}

//
// NSFetchRequest Utils
//
public extension CDataCRUDEntity {
    typealias DBEntity = CDataCRUDEntity

    static var idFields: [String] { ["id"] }

    static func fetchRequest(id: String) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        request.predicate = NSPredicate.anyField(DBEntity.idFields, with: id)
        return request
    }

    static func fetchRequestAll(sorted: Bool) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        if sorted {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DBEntity.recordDate, ascending: true)]
        }
        return request
    }

    static func fetchRequestWith(key: String) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        request.predicate = NSPredicate.anyField(DBEntity.idFields, with: key)
        request.fetchLimit = 1
        return request
    }
}
