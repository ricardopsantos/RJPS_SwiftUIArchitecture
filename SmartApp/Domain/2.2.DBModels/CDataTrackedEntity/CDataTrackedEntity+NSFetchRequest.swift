//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation
import CoreData
//
// NSFetchRequest Utils
//
public extension CDataTrackedEntity {
    typealias DBEntity = CDataTrackedEntity

    static var idFields: [String] { ["id"] }

    static func fetchRequestAll(sorted: Bool = false) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        if sorted {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DBEntity.favorite, ascending: true)]
        }
        return request
    }

    static func fetchRequestWith(id: String) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        request.predicate = NSPredicate.anyField(DBEntity.idFields, with: id)
        request.fetchLimit = 1
        return request
    }
}
