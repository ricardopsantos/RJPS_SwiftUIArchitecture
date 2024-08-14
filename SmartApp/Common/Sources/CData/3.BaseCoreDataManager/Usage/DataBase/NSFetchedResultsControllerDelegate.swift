//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation
import CoreData

//
// MARK: - NSFetchedResultsControllerDelegate
//

extension CommonCoreData.Utils.Sample.CRUDEntityDBRepository: NSFetchedResultsControllerDelegate {
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
        if let object = anObject as? CDataCRUDEntity {
            id = object.id ?? ""
            dbModelName = "\(CDataCRUDEntity.self)"
        }

        if let id = id, let dbModelName = dbModelName {
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
        if controller == fetchedResultsController {
            dbModelName = "\(CDataCRUDEntity.self)"
        }
        if let dbModelName = dbModelName {
            Self.emit(event: .generic(.databaseDidFinishChangeContentItemsOn(dbModelName)))
        } else {
            Common_Logs.error("Not predicted for \(controller)")
        }
    }
}
