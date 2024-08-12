//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public extension CommonCoreDataNameSpace {
    class SyncCoreDataManager: SyncCoreDataManagerCRUDProtocol {
        private let dbName: String
        private let managedObjectModel: NSManagedObjectModel!

        public init(dbName: String, dbBundle: String) {
            self.managedObjectModel = Utils.managedObjectModelWith(
                dbName: dbName,
                dbBundle: dbBundle
            )
            self.dbName = dbName
        }

        public lazy var storeContainer: NSPersistentContainer = {
            Utils.storeContainer(dbName: dbName, managedObjectModel: managedObjectModel, storeInMemory: false)
        }()

        public lazy var viewContext: NSManagedObjectContext = {
            Utils.mainViewContext(storeContainer: storeContainer)
        }()

        public lazy var mainViewContext: NSManagedObjectContext = {
            Utils.mainViewContext(storeContainer: storeContainer)
        }()

        public lazy var privateViewContext: NSManagedObjectContext = {
            Utils.privateViewContext(parentContext: mainViewContext)
        }()

        public var newPrivateViewContext: NSManagedObjectContext {
            Utils.privateViewContext(parentContext: mainViewContext)
        }
    }
}
