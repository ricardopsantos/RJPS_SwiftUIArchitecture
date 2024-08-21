//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation
import CoreData
import Combine

//
// MARK: - CommonDataBaseRepository
//

public class CommonDataBaseRepository: CommonBaseCoreDataManager {
    private (set) var fetchedResultsControllerDic: [String: NSFetchedResultsController<NSManagedObject>] = [:]
    public static var shared = CommonDataBaseRepository(
        dbName: Common.internalDB,
        dbBundle: Common.bundleIdentifier
    )
    override private init(dbName: String, dbBundle: String) {
        super.init(dbName: dbName, dbBundle: dbBundle)
    }

    public override func startFetchedResultsController() {
        guard fetchedResultsControllerDic.count == 0 else {
            return
        }
        
        // Create the controller with specific type
        fetchedResultsControllerDic["\(CDataCRUDEntity.self)"] = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: CDataCRUDEntity.fetchRequestAll(sorted: true) as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsControllerDic["\(CDataSinger.self)"] = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: CDataSinger.fetchRequestAll(sorted: true) as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsControllerDic["\(CDataSong.self)"] = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: CDataSong.fetchRequestAll(sorted: true) as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsControllerDic.forEach({ (_, controller) in
            controller.delegate = self
            try? controller.performFetch()
        })
        
    }
}


