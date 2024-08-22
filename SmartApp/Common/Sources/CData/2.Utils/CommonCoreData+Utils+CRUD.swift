//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// MARK: - Utils CRUD operations
//

public extension CommonCoreData.Utils {
    @discardableResult
    static func batchDelete(
        context: NSManagedObjectContext,
        request: NSFetchRequest<NSFetchRequestResult>
    ) -> Bool {
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeCount
            try context.execute(deleteRequest)
            try context.save()
            try context.parent?.save()
            return true
        } catch {
            context.rollback()
            Common_Logs.error("Log_\(Self.logNumber += 1): Couldn't delete the entities " + error.localizedDescription)
            return false
        }
    }

    @discardableResult
    /// Saves the context, at the same time it prints debug messages
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
            changes = "# Updated \(relatedObjects.count) of \(className)"
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
        if logsEnabled, !changes.isEmpty, !Common.Utils.onUITests/*, !Common.Utils.onUnitTests */{
            Common_Logs.debug(" 💾 \(Self.logNumber) - \(changes) @ \(threadInfo)")
            Self.logNumber += 1
        }
        return saveSuccess
    }
}
