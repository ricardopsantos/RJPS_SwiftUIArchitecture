//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation

public extension CommonCoreData.Utils {
    struct Sample {}
}

public extension CommonCoreData.Utils.Sample {
    static func crudTest() {
        crudTestSync()
        Task {
            await crudTestAsync()
        }
    }

    static func crudTestSync() {
        let bd = CommonCoreData.Utils.Sample.DataBaseRepository.shared

        bd.syncClearAll()
        if bd.syncRecordCount() != 0 {
            fatalError("Should be 0")
        }

        let storedUser: CommonCoreData.Utils.Sample.CRUDEntity = .random
        bd.syncStore(storedUser)
        bd.syncStore(.random)

        if bd.syncRecordCount() != 2 {
            fatalError("Should be 2")
        }

        let ids = bd.syncAllIds()
        if ids.count != 2 {
            fatalError("Should be 2")
        }

        if bd.syncRecordCount() != 2 {
            fatalError("Should be 2")
        }
        if let retrieveUser = bd.syncRetrieve(key: storedUser.id) {
            if retrieveUser != storedUser {
                fatalError("Should be equal")
            }
        } else {
            fatalError("Should had found")
        }

        bd.syncClearAll()

        if bd.syncRecordCount() != 0 {
            fatalError("Should be 0")
        }
    }

    static func crudTestAsync() async {
        let bd = CommonCoreData.Utils.Sample.DataBaseRepository.shared

        await bd.aSyncClearAll()
        if await bd.aSyncRecordCount() != 0 {
            fatalError("Should be 0")
        }

        let storedUser: CommonCoreData.Utils.Sample.CRUDEntity = .random
        await bd.aSyncStore(storedUser)
        await bd.aSyncStore(.random)

        if await bd.aSyncRecordCount() != 2 {
            fatalError("Should be 2")
        }

        let ids = await bd.aSyncAllIds()
        if ids.count != 2 {
            fatalError("Should be 2")
        }

        if let retrieveUser = await bd.aSyncRetrieve(key: storedUser.id) {
            if retrieveUser != storedUser {
                fatalError("Should be equal")
            }
        } else {
            fatalError("Should had found")
        }

        await bd.aSyncClearAll()
        if await bd.aSyncRecordCount() != 0 {
            fatalError("Should be 0")
        }
    }
}
