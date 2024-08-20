//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public extension CommonCoreData {
    class BaseCoreDataManager: NSObject, SyncCoreDataManagerCRUDProtocol {
        //
        // MARK: - Usage Propertyes
        //
        let managedObjectModel: NSManagedObjectModel
        let persistentContainer: NSPersistentContainer!

        //
        // MARK: - Config
        //
        func viewContextIsShared() -> Bool {
            // Can be overridden
            false
        }

        func startFetchedResultsController() {
            // Can be overridden
        }

        public init(dbName: String, dbBundle: String) {
            if let nsManagedObjectModel = CommonCoreData.Utils.managedObjectModel(dbName: dbName, dbBundle: dbBundle) {
                self.managedObjectModel = nsManagedObjectModel
            } else if let nsManagedObjectModel = CommonCoreData.Utils.managedObjectModelForSPM(dbName: dbName) {
                self.managedObjectModel = nsManagedObjectModel
            } else {
                fatalError("fail to load managedObjectModel")
            }
            if let persistentContainer = CommonCoreData.Utils.buildPersistentContainer(
                dbName: dbName,
                managedObjectModel: managedObjectModel,
                storeInMemory: false
            ) {
                self.persistentContainer = persistentContainer
            } else {
                fatalError("fail to load persistentContainer")
            }
            super.init()
            startFetchedResultsController()
        }

        public func save() {
            saveContext()
        }
        
        /// Default View Context
        public var viewContext: NSManagedObjectContext {
            viewContextIsShared() ? lazyViewContext : newViewContextInstance
        }

        public var backgroundContext: NSManagedObjectContext {
            let context = persistentContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            return context
        }

        //
        // MARK: - Private
        //
        private var newViewContextInstance: NSManagedObjectContext {
            if Common_Utils.false {
                return Utils.mainViewContext(storeContainer: persistentContainer, automaticallyMergesChangesFromParent: true)
            } else {
                let context = persistentContainer.viewContext
                context.automaticallyMergesChangesFromParent = true
                return context
            }
        }

        private lazy var lazyViewContext: NSManagedObjectContext = {
            if Common_Utils.false {
                return Utils.mainViewContext(storeContainer: persistentContainer, automaticallyMergesChangesFromParent: true)
            } else {
                let context = persistentContainer.viewContext
                context.automaticallyMergesChangesFromParent = true
                return context
            }
        }()
    }
}
