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
}
