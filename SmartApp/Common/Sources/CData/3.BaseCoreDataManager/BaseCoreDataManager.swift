//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public extension CommonCoreData {
    class BaseCoreDataManager: SyncCoreDataManagerCRUDProtocol {
        let managedObjectModel: NSManagedObjectModel
        let dbName: String
        let persistentContainer: NSPersistentContainer!
        public init(dbName: String, dbBundle: String) {
            if let nsManagedObjectModel = CommonCoreData.Utils.managedObjectModelV1(dbName: dbName, dbBundle: dbBundle) {
                self.managedObjectModel = nsManagedObjectModel
            } else if let nsManagedObjectModel = CommonCoreData.Utils.managedObjectModelV2(dbName: dbName) {
                self.managedObjectModel = nsManagedObjectModel
            } else {
                fatalError("fail to load managedObjectModel")
            }
            self.dbName = dbName
            if let persistentContainer = CommonCoreData.Utils.buildPersistentContainer(
                dbName: dbName,
                managedObjectModel: self.managedObjectModel,
                storeInMemory: false
            ) {
                self.persistentContainer = persistentContainer
            } else {
                fatalError("fail to load persistentContainer")
            }
        }

        public var viewContext: NSManagedObjectContext {
            if Common_Utils.false {
                return Utils.mainViewContext(storeContainer: persistentContainer, automaticallyMergesChangesFromParent: true)
            } else {
                let context = persistentContainer.viewContext
                context.automaticallyMergesChangesFromParent = true
                return context
            }
        }

        public var backgroundContext: NSManagedObjectContext {
            let context = persistentContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            return context
        }
    }
}
