//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// MARK: - NSManagedObjectModel
//

public extension CommonCoreData.Utils {
    static func managedObjectModelV1(
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
    
    // When using SwiftPackage Manager
    static func managedObjectModelV2(
        dbName: String
    ) -> NSManagedObjectModel? {
        print("fix")
        /*
        guard let modelURL = Bundle.module.url(forResource: dbName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            return  nil
    }
        return managedObjectModel*/
        return nil
    }
}
