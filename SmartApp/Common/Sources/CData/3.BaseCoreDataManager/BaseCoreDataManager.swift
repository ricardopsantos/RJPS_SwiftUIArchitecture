//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public extension CommonCoreDataNameSpace {
    class BaseCoreDataManager: SyncCoreDataManagerCRUDProtocol {
        let managedObjectModel: NSManagedObjectModel
        let dbName: String
        let persistentContainer: NSPersistentContainer
        public init(dbName: String, dbBundle: String) {
            let nsManagedObjectModel = CommonCoreDataNameSpace.Utils.managedObjectModelWith(
                dbName: dbName,
                dbBundle: dbBundle
            )!
            self.dbName = dbName
            self.managedObjectModel = nsManagedObjectModel
            self.persistentContainer = CommonCoreDataNameSpace.Utils.storeContainer(
                dbName: dbName,
                managedObjectModel: nsManagedObjectModel,
                storeInMemory: false
            )
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
