//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation
import CoreData

//
// NSFetchRequest Utils
//
public extension CDataSong {
    typealias DBEntity = CDataSong

    static var idFields: [String] { ["id"] }

    static func fetchRequestAll(sorted: Bool = false) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        if sorted {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DBEntity.releaseDate, ascending: true)]
        }
        return request
    }

    static func fetchBy(singer: CDataSinger, sorted: Bool = false) -> NSFetchRequest<DBEntity> {
        let request = NSFetchRequest<DBEntity>(entityName: DBEntity.entityName)
        request.predicate = NSPredicate(format: "singer = %@", singer)
        if sorted {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DBEntity.releaseDate, ascending: true)]
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
