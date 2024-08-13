//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// MARK: - NSPersistentContainer
//

public extension CommonCoreData.Utils {
    static func storeContainer(
        dbName: String,
        managedObjectModel: NSManagedObjectModel,
        storeInMemory: Bool
    ) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: dbName, managedObjectModel: managedObjectModel)
        let tables = container.managedObjectModel.entitiesByName.keys.description
        let version = managedObjectModel.versionIdentifiers.description.replace("AnyHashable", with: "")
        if storeInMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error {
                Common_Logs.error("Unresolved error \(error), \(error.localizedDescription)")
            } else {
                if let persistentStoreURL = container.persistentStoreCoordinator.persistentStores.first?.url {
                    do {
                        let fileAttributes = try FileManager.default.attributesOfItem(atPath: persistentStoreURL.path)
                        if let fileSize = fileAttributes[.size] as? Int64 {
                            let fileSizeInMB = Double(fileSize) / (1024 * 1024)
                            let report = """
                            Loaded DataBase \(dbName)
                              • name: \(dbName)
                              • version: \(version)
                              • tables: \(tables)
                              • size: \(fileSizeInMB) MB
                            """
                            Common_Logs.debug(report)
                        }
                    } catch {
                        Common_Logs.error(error.localizedDescription)
                    }
                }
            }
        }
        return container
    }
}
