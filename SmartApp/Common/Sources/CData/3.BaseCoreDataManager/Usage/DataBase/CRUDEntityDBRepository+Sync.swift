//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation
import CoreData

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
