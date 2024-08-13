//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// MARK: - NSManagedObjectContext
//

public extension CommonCoreData.Utils {
    /// mainQueue: __This property returns an instance of NSManagedObjectContext that is configured to operate on the main queue.__
    /// It means any operations performed using this context will be executed on the main thread. The main queue context is used for user interface
    /// interactions since UIKit and other UI frameworks require UI updates to be done on the main thread.
    static func mainViewContext(
        storeContainer: NSPersistentContainer,
        automaticallyMergesChangesFromParent: Bool
    ) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = storeContainer.viewContext.persistentStoreCoordinator
        if automaticallyMergesChangesFromParent {
            context.automaticallyMergesChangesFromParent = true
        }
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
    static func privateViewContext(
        parentContext: NSManagedObjectContext,
        automaticallyMergesChangesFromParent: Bool
    ) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        if automaticallyMergesChangesFromParent {
            context.automaticallyMergesChangesFromParent = automaticallyMergesChangesFromParent
        }
        context.parent = parentContext
        return context
    }

    static func privateViewContext(
        storeContainer: NSPersistentContainer,
        automaticallyMergesChangesFromParent: Bool
    ) -> NSManagedObjectContext {
        let mainViewContext = mainViewContext(
            storeContainer: storeContainer,
            automaticallyMergesChangesFromParent: automaticallyMergesChangesFromParent
        )
        if automaticallyMergesChangesFromParent {
            mainViewContext.automaticallyMergesChangesFromParent = true
        }
        return privateViewContext(
            parentContext: mainViewContext,
            automaticallyMergesChangesFromParent: automaticallyMergesChangesFromParent
        )
    }
}
