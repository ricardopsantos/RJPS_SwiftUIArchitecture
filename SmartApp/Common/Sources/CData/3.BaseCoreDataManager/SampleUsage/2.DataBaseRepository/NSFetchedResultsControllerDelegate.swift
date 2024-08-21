//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation
import CoreData

//
// MARK: - NSFetchedResultsControllerDelegate
//

extension CommonDataBaseRepository: NSFetchedResultsControllerDelegate {
    // This method serves as a preparation step before the individual changes are processed.
    // It's often used to signal the start of a batch update operation and can be used to perform
    // any necessary setup before applying the changes.
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // You can perform any necessary setup before the changes are applied
    }

    // This method is called for every change that occurs to the managed objects in the fetched results controller.
    // It provides detailed information about the change, including what type of change occurred (insert, delete,
    // update, move), the index paths of the affected objects before and after the change, and the type of change.
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        var dbModelName: String?
        var id: String?
        if Common_Utils.false {
            if let object = anObject as? CDataCRUDEntity {
                id = object.id ?? ""
                dbModelName = "\(CDataCRUDEntity.self)"
            }
        } else {
            /// `<CDataCRUDEntity: 0x60000211c280>` --> `CDataCRUDEntity`
            dbModelName = "\(anObject.self)".dropFirstIf("<").split(by: ":").first
            ["id", "identifier", "key", ].forEach { key in
                if let some = (anObject as AnyObject).value(forKey: "id"), !"\(some)".isEmpty {
                    id = "\(some)"
                }
            }
        }
        
        if let dbModelName = dbModelName {
            switch type {
            case .insert:
                Self.emit(event: .generic(.databaseDidInsertedContentOn(dbModelName, id: id)))
            case .delete:
                Self.emit(event: .generic(.databaseDidDeletedContentOn(dbModelName, id: id)))
            case .move, .update:
                Self.emit(event: .generic(.databaseDidUpdatedContentOn(dbModelName, id: id)))
            @unknown default: ()
            }
            Self.emit(event: .generic(.databaseDidChangedContentItemOn(dbModelName)))
        } else {
            Common_Logs.error("Not predicted for \(anObject)")
        }
    }

    // This method is called when all the changes have been processed. It's a signal that the
    // fetched results controller's content has been fully updated. You typically use this method
    // to perform any final UI updates or batch processing that you want to do after a series of changes.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        var dbModelName: String?
        fetchedResultsControllerDic.forEach { (key, value) in
            if controller == value {
                dbModelName = key
            }
        }
        if let dbModelName = dbModelName {
            Self.emit(event: .generic(.databaseDidFinishChangeContentItemsOn(dbModelName)))
        } else {
            Common_Logs.error("Not predicted for \(controller)")
        }
    }
}
