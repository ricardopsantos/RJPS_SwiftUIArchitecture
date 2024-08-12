//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2023 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData
import Combine

import Foundation

//
// MARK: - NSFetchRequest Utils
//

public extension CDataExpiringKeyValueEntity {
    typealias DBEntity = CDataExpiringKeyValueEntity

    static var idFields: [String] { ["key"] }

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
        return request
    }
}
