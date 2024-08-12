//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public extension CommonCoreDataNameSpace {
    struct Utils {
        private static var logsEnabled = true
        private static var logNumber = 1
        private init() {}
    }
}

//
// MARK: - Utils getters
//

public extension CommonCoreDataNameSpace.Utils {
    /// mainQueue: __This property returns an instance of NSManagedObjectContext that is configured to operate on the main queue.__
    /// It means any operations performed using this context will be executed on the main thread. The main queue context is used for user interface
    /// interactions since UIKit and other UI frameworks require UI updates to be done on the main thread.
    static func mainViewContext(storeContainer: NSPersistentContainer) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = storeContainer.viewContext.persistentStoreCoordinator
        context.automaticallyMergesChangesFromParent = true
        if let persistentStoreURL = context.persistentStoreCoordinator?.persistentStores.first?.url {
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: persistentStoreURL.path)
                if let fileSize = fileAttributes[.size] as? Int64 {
                    let fileSizeInMB = Double(fileSize) / (1024 * 1024)
                    Common_Logs.debug("Loaded DB with size: \(fileSizeInMB) MB")
                }
            } catch {
                Common_Logs.error(error.localizedDescription)
            }
        }
        return context
    }

    /// privateQueue: __This property returns an instance of NSManagedObjectContext that is configured to operate on a private background queue.__
    /// It means any operations performed using this context will be executed on a background queue (not the main queue). This is typically used for performing
    /// data processing tasks or background updates without blocking the main thread. It is important to use private queue contexts for heavy or time-consuming
    /// operations to keep the main user interface responsive.
    static func privateViewContext(parentContext: NSManagedObjectContext) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.automaticallyMergesChangesFromParent = true
        context.parent = parentContext
        return context
    }

    static func privateViewContext(storeContainer: NSPersistentContainer) -> NSManagedObjectContext {
        let mainViewContext = mainViewContext(storeContainer: storeContainer)
        mainViewContext.automaticallyMergesChangesFromParent = true
        return privateViewContext(parentContext: mainViewContext)
    }

    static func managedObjectModelWith(
        dbName: String,
        dbBundle: String
    ) -> NSManagedObjectModel? {
        guard let bundle = Bundle(identifier: dbBundle),
              let modelURL = bundle.url(forResource: dbName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }
        return managedObjectModel
    }

    static func storeContainer(
        dbName: String,
        managedObjectModel: NSManagedObjectModel,
        storeInMemory: Bool
    ) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: dbName, managedObjectModel: managedObjectModel)
        if storeInMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error {
                Common_Logs.error("Unresolved error \(error), \(error.localizedDescription)")
            } else {
                Common_Logs.debug("Loaded DB [\(dbName)]")
            }
        }
        return container
    }
}

//
// MARK: - Utils CRUD operations
//

public extension CommonCoreDataNameSpace.Utils {
    static func delete(viewContext: NSManagedObjectContext, request: NSFetchRequest<NSFetchRequestResult>) {
        do {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            batchDeleteRequest.resultType = .resultTypeCount
            try viewContext.execute(batchDeleteRequest)
        } catch {
            Common_Logs.error("Couldn't delete the entities " + error.localizedDescription)
        }
    }

    @discardableResult
    static func save(viewContext: NSManagedObjectContext?) -> Bool {
        guard let viewContext, viewContext.hasChanges else {
            return false
        }
        var saveSuccess = false
        let threadInfo: String = (Thread.isMain ? "Main" : "Background") + " Thread"
        var changes = ""
        #if DEBUG
        if !viewContext.insertedObjects.isEmpty {
            let relatedObjects = viewContext.insertedObjects
            let className = relatedObjects.first?.entity.name ?? ""
            changes = "# Inserted \(relatedObjects.count) of \(className)"
        }
        if !viewContext.deletedObjects.isEmpty {
            let relatedObjects = viewContext.deletedObjects
            let className = relatedObjects.first?.entity.name ?? ""
            changes = "# Deleted \(relatedObjects.count) of \(className)"
        }
        if !viewContext.updatedObjects.isEmpty {
            let relatedObjects = viewContext.updatedObjects
            let className = relatedObjects.first?.entity.name ?? ""
            changes = "# Updated \(relatedObjects.count) of \(className)!"
        }
        #endif
        switch viewContext.concurrencyType {
        case .privateQueueConcurrencyType, .confinementConcurrencyType:
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = viewContext
            privateContext.performAndWait { [weak viewContext, weak privateContext] in
                do {
                    try privateContext?.save()
                    try viewContext?.save()
                    saveSuccess = true
                } catch {
                    viewContext?.rollback()
                    let nserror = error as NSError
                    Common_Logs.error("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        case .mainQueueConcurrencyType:
            do {
                try viewContext.save()
                if let parent = viewContext.parent, parent.hasChanges {
                    try parent.save()
                }
                saveSuccess = true
            } catch {
                viewContext.rollback()
                let nserror = error as NSError
                Common_Logs.error("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        @unknown default:
            ()
        }
        if logsEnabled, !changes.isEmpty, !Common.Utils.onUITests, !Common.Utils.onUnitTests {
            Common_Logs.debug(" 💾 \(Self.logNumber) - \(changes) @ \(threadInfo)")
            Self.logNumber += 1
        }
        return saveSuccess
    }
}
