//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// Just use anywhere hearn the protocol extension behavior
// Inspired on : https://medium.com/dev-genius/ios-core-data-with-sugar-syntax-ef53a0e06efe
//

public protocol SyncCoreDataManagerCreatingProtocol {
    var viewContext: NSManagedObjectContext { get }
    func createEntity<T: NSManagedObject>() -> T
}

public extension SyncCoreDataManagerCreatingProtocol {
    func createEntity<T: NSManagedObject>() -> T {
        T(context: viewContext)
    }
}
