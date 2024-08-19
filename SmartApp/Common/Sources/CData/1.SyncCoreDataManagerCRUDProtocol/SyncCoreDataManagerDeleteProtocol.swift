//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

//
// Just use anywhere earn the protocol extension behaviour
// Inspired on : https://medium.com/dev-genius/ios-core-data-with-sugar-syntax-ef53a0e06efe
//

public protocol SyncCoreDataManagerDeleteProtocol {
    var viewContext: NSManagedObjectContext { get }
    func delete(request: NSFetchRequest<NSFetchRequestResult>)
}

public extension SyncCoreDataManagerDeleteProtocol {
    func delete(request: NSFetchRequest<NSFetchRequestResult>) {
        CommonCoreData.Utils.batchDelete(context: viewContext, request: request)
    }
}
