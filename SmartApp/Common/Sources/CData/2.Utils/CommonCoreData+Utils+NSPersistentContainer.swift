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
    static func buildPersistentContainer(
        dbName: String,
        managedObjectModel: NSManagedObjectModel,
        storeInMemory: Bool
    ) -> NSPersistentContainer? {
        // guard let modelURL = Bundle.module.url(forResource: dbName, withExtension: "momd") else { return  nil }
        // guard let model = NSManagedObjectModel(contentsOf: modelURL) else { return nil }
        // let containerV1 = NSPersistentContainer(name:dbName, managedObjectModel:model)

        let container = NSPersistentContainer(name: dbName, managedObjectModel: managedObjectModel)

        if storeInMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error {
                Common_Logs.error("Log_\(Self.logNumber += 1): Unresolved error \(error), \(error.localizedDescription)")
            } else {
                CommonCoreData.Utils.printDBReport(
                    dbName: dbName,
                    container: container,
                    managedObjectModel: managedObjectModel
                )
            }
        }
        return container
    }
}

//
// MARK: - NSPersistentContainer
//

public extension CommonCoreData.Utils {
    static func printDBReport(dbName: String, container: NSPersistentContainer, managedObjectModel: NSManagedObjectModel) {
        let tables = container.managedObjectModel.entitiesByName.keys.description
        let version = managedObjectModel.versionIdentifiers.description.replace("AnyHashable", with: "")
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
                    Common_Logs.debug("Log_\(Self.logNumber += 1): \(report)")
                }
            } catch {
                Common_Logs.error("Log_\(Self.logNumber += 1): \(error.localizedDescription)")
            }
        }
    }
}
