//
//  Created by Ricardo Santos on 14/08/2024.
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
// MARK: - CRUDEntityDBRepository / Sync Methods
//
public extension CommonCoreData.Utils.Sample.CRUDEntityDBRepository {
    func syncStore(_ model: CommonCoreData.Utils.Sample.CRUDEntity) {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        let newInstance: DBEntity = DBEntity(context: context)
        newInstance.id = model.id
        newInstance.name = model.name
        newInstance.recordDate = model.recordDate
        if context.hasChanges {
            try? context.save()
        }
    }

    func syncStoreBatch(_ models: [CommonCoreData.Utils.Sample.CRUDEntity]) {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        let batchRequest = NSBatchInsertRequest(entity: DBEntity.entity(), objects: models.map { model in
            model.mapToDic
        })
        if context.hasChanges || Common_Utils.true { // Dont check for changes on Batch, they don't appear
            _ = try? context.execute(batchRequest)
        }
    }

    func syncUpdate(_ model: CommonCoreData.Utils.Sample.CRUDEntity) {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        let instances = try? context.fetch(DBEntity.fetchRequestWith(id: model.id))
        if let existingEntity = instances?.first {
            existingEntity.name = model.name
            existingEntity.recordDate = model.recordDate
            if context.hasChanges {
                try? context.save()
            }
        }
    }

    func syncDelete(_ model: CommonCoreData.Utils.Sample.CRUDEntity) {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        let instances = try? context.fetch(DBEntity.fetchRequestWith(id: model.id))
        if let existingEntity = instances?.first {
            context.delete(existingEntity)
            if context.hasChanges {
                try? context.save()
            }
        }
    }

    func syncRecordCount() -> Int {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        return (try? context.count(for: DBEntity.fetchRequest())) ?? 0
    }

    func syncClearAll() {
        guard syncRecordCount() > 0 else { return }
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        CommonCoreData.Utils.batchDelete(context: context, request: DBEntity.fetchRequest())
    }

    func syncRetrieve(key: String) -> CommonCoreData.Utils.Sample.CRUDEntity? {
        typealias DBEntity = CDataCRUDEntity
        let context = viewContext
        do {
            let record = try? context
                .fetch(DBEntity.fetchRequestWith(id: key))
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

    func syncAllIds() -> [String] {
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
