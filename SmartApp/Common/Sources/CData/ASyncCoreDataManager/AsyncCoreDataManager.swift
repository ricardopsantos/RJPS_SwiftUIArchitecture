//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import CoreData

public extension CommonCoreDataNameSpace {
    class AsyncCoreDataManager: AsyncCoreDataManagerCRUDProtocol {
        private let storeContainer: NSPersistentContainer

        public lazy var viewContext: NSManagedObjectContext = {
            mainViewContext
        }()

        public lazy var mainViewContext: NSManagedObjectContext = {
            Utils.mainViewContext(storeContainer: storeContainer)
        }()

        public lazy var privateViewContext: NSManagedObjectContext = {
            Utils.privateViewContext(parentContext: mainViewContext)
        }()

        public func reset() {
            mainViewContext.reset()
            privateViewContext.reset()
        }

        public convenience init(
            dbName: String,

            in storageType: CommonCoreDataNameSpace.StorageType = .persistent,
            dbBundle: String
        ) {
            guard let managedObjectModel = Utils.managedObjectModelWith(dbName: dbName, dbBundle: dbBundle) else {
                fatalError("Invalid name or bundle")
            }
            self.init(dbName: dbName, in: storageType, managedObjectModel: managedObjectModel)
        }

        public init(
            dbName: String,
            in storageType: CommonCoreDataNameSpace.StorageType = .persistent,
            managedObjectModel: NSManagedObjectModel
        ) {
            self.storeContainer = Utils.storeContainer(
                dbName: dbName,
                managedObjectModel: managedObjectModel,
                storeInMemory: storageType == .inMemory
            )
        }
    }
}
