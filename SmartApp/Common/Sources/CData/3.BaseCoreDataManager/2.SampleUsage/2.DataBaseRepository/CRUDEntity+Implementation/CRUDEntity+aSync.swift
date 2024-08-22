//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation
import CoreData

/**

 6 Performance Improvements for Core Data in iOS Apps

 https://stevenpcurtis.medium.com/5-performance-improvements-for-core-data-in-ios-apps-2dbd1ab5d601

 * Avoid using the viewContext for writes and only use it for reads on the main thread.
 * Only save your managed object context if it has changes to prevent unnecessary work.
 * Use NSInMemoryStoreType to test your Core Data implementation without hitting the disk.
 * Consider using multiple managed object contexts to better manage changes and save off the main thread.
 * Use fetch requests to only access the data you need and be mindful of predicates to avoid over-fetching.
 * Use batch processing with NSBatchUpdateRequest and NSBatchDeleteRequest to save time and resources when working with large amounts of data.
 */

//
// MARK: - CRUDEntityDBRepository / Async Methods
//
extension CommonDataBaseRepository {
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
                if Common_Utils.true {
                    CommonCoreData.Utils.save(viewContext: context)
                } else {
                    if context.hasChanges {
                        try? context.save()
                    }
                }
                continuation.resume()
            }
        }
    }

    func aSyncStoreBatch(_ models: [CommonCoreData.Utils.Sample.CRUDEntity]) async {
        typealias DBEntity = CDataCRUDEntity
        let context = backgroundContext // Use a background context to perform the operation asynchronously
        await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                let batchRequest = NSBatchInsertRequest(entity: DBEntity.entity(), objects: models.map { model in
                    model.mapToDic
                })
                if context.hasChanges || Common_Utils.true { // Dont check for changes on Batch, they don't appear
                    _ = try? context.execute(batchRequest)
                }
                continuation.resume()
            }
        }
    }

    func aSyncUpdate(_ model: CommonCoreData.Utils.Sample.CRUDEntity) async {
        typealias DBEntity = CDataCRUDEntity
        let context = backgroundContext // Use a background context to perform the operation asynchronously
        await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                let instances = try? context.fetch(DBEntity.fetchRequestWith(id: model.id))
                if let existingEntity = instances?.first {
                    existingEntity.name = model.name
                    existingEntity.recordDate = model.recordDate
                    if Common_Utils.true {
                        CommonCoreData.Utils.save(viewContext: context)
                    } else {
                        if context.hasChanges {
                            try? context.save()
                        }
                    }
                }
                continuation.resume()
            }
        }
    }

    func aSyncDelete(_ model: CommonCoreData.Utils.Sample.CRUDEntity) async {
        typealias DBEntity = CDataCRUDEntity
        let context = backgroundContext // Use a background context to perform the operation asynchronously
        await withCheckedContinuation { [weak context] continuation in
            context?.performAndWait { [weak context] in
                guard let context = context else {
                    return
                }
                let instances = try? context.fetch(DBEntity.fetchRequestWith(id: model.id))
                if let existingEntity = instances?.first {
                    context.delete(existingEntity)
                    if Common_Utils.true {
                        CommonCoreData.Utils.save(viewContext: context)
                    } else {
                        if context.hasChanges {
                            try? context.save()
                        }
                    }
                }
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
                CommonCoreData.Utils.batchDelete(context: context, request: DBEntity.fetchRequest())
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
                    .fetch(DBEntity.fetchRequestWith(id: key))
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
