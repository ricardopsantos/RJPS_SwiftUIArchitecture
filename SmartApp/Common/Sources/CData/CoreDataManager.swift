//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public extension CommonCoreDataNameSpace {
    class CoreDataManager {
        private let dbName: String
        private let dbBundle: String
        public init(dbName: String, dbBundle: String) {
            self.dbName = dbName
            self.dbBundle = dbBundle
        }

        public /* lazy */ var syncInstance: (manager: SyncCoreDataManager, viewContext: NSManagedObjectContext) {
            let manager = SyncCoreDataManager(dbName: dbName, dbBundle: dbBundle)
            return (manager, manager.viewContext)
        }

        public /* lazy */ var aSyncInstance: (manager: AsyncCoreDataManager, viewContext: NSManagedObjectContext) {
            let manager = AsyncCoreDataManager(dbName: dbName, dbBundle: dbBundle)
            return (manager, manager.viewContext)
        }
    }
}
