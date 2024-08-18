//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// MARK: - NSManagedObjectModel
//

extension Bundle {
    static let spmBundle = Bundle(path: "\(Bundle.main.bundlePath)/resource/bundle")
}

public extension CommonCoreData.Utils {
    static func managedObjectModel(
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

    /// When using SwiftPackage Manager
    /// Bundle.module is automatically generated for any package target that includes at least one resource.
    static func managedObjectModelForSPM(
        dbName: String
    ) -> NSManagedObjectModel? {
        #if IN_PACKAGE_CODE
        guard let modelURL = Bundle.module.url(forResource: dbName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }
        return managedObjectModel
        #else
        return nil
        #endif
    }
}
