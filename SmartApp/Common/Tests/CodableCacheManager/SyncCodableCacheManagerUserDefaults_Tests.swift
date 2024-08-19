import XCTest
import Foundation
import Combine
//
import Nimble

@testable import Common

final class SyncCodableCacheManagerUserDefaults_Tests: SyncCodableCacheManagerBase_Tests {
    override func enabled() -> Bool {
        true
    }
    
    override func codableCacheManager() -> CodableCacheManagerProtocol {
        Common.CacheManagerForCodableUserDefaultsRepository.shared
    }
}

final class SyncCodableCacheManagerCoreData_Tests: SyncCodableCacheManagerBase_Tests {
    override func enabled() -> Bool {
        true
    }
    
    override func codableCacheManager() -> CodableCacheManagerProtocol {
        Common.CacheManagerForCodableCoreDataRepository.shared
    }
}
