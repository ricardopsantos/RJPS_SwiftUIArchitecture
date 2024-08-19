//
//  Created by Ricardo Santos on 12/08/2024.
//

import XCTest
import Foundation
import Combine
//
import Nimble
//
@testable import Common
class EncryptionManager_Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel()
    }
    
    func test_string() {
        let string = String.randomWithSpaces(1000)
        
        let aesCBCEncrypted = Common.EncryptionManager.encrypt(string: string, method: .aesCBC).base64Encoded
        let aesGCMEncrypted = Common.EncryptionManager.encrypt(string: string, method: .aesGCM).base64Encoded
        
        let aesCBCDecrypted = Common.EncryptionManager.decrypt(base64String: aesCBCEncrypted, method: .aesCBC)
        let aesGCMDecrypted = Common.EncryptionManager.decrypt(base64String: aesGCMEncrypted, method: .aesGCM)
        
        XCTAssert(aesCBCDecrypted == string)
        XCTAssert(aesGCMDecrypted == string)
    }
    
    func test_data() {
        let entity: CommonCoreData.Utils.Sample.CRUDEntity = .random
        let data = try? JSONEncoder().encode(entity)
        
        let aesCBCEncrypted = Common.EncryptionManager.encrypt(data: data, method: .aesCBC)
        let aesGCMEncrypted = Common.EncryptionManager.encrypt(data: data, method: .aesGCM)
        
        let aesCBCDecrypted = Common.EncryptionManager.decrypt(data: aesCBCEncrypted, method: .aesCBC)
        let aesGCMDecrypted = Common.EncryptionManager.decrypt(data: aesGCMEncrypted, method: .aesGCM)
        
        XCTAssert(aesCBCDecrypted == data)
        XCTAssert(aesGCMDecrypted == data)
    }
    
    func test_stringExtension() {
        let string = String.randomWithSpaces(1000)
        let encrypted = string.encrypted
        let decrypted = encrypted?.decrypted
        XCTAssert(string == decrypted)
    }
    
    func test_dataExtension() {
        let entity: CommonCoreData.Utils.Sample.CRUDEntity = .random
        if let data = try? JSONEncoder().encode(entity) {
            let encrypted = data.encrypted
            let decrypted = encrypted?.decrypted
            XCTAssert(data == decrypted)
        } else {
            XCTAssert(false)
        }
    }
}
