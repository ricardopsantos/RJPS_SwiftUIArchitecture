//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public protocol AsyncCoreDataManagerSaveProtocol {
    var viewContext: NSManagedObjectContext { get }
    func publisher(save action: @escaping ASyncCoreDataManagerPublisherAction) -> ASyncCoreDataManagerSavePublisher
    func reset()
}

public extension AsyncCoreDataManagerSaveProtocol {
    func publisher(save action: @escaping ASyncCoreDataManagerPublisherAction) -> ASyncCoreDataManagerSavePublisher {
        ASyncCoreDataManagerSavePublisher(action: action, context: viewContext)
    }
}
