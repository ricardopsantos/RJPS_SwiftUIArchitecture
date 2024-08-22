//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation
import CoreData
//
// NSFetchRequest Utils
//

public extension CDataTrackedLog {
    typealias DBEntity = CDataTrackedLog

    static var idFields: [String] { ["id"] }

    static func fetchRequestAll(sorted: Bool = false) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        if sorted {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DBEntity.recordDate, ascending: true)]
        }
        return request
    }

    static func fetchRequestWith(id: String) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        request.predicate = NSPredicate.anyField(DBEntity.idFields, with: id)
        request.fetchLimit = 1
        return request
    }

    static func fetchRequestWith(relationship: CDataTrackedEntity) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        request.predicate = NSPredicate(format: "relationship = %@", relationship)
        return request
    }
}
