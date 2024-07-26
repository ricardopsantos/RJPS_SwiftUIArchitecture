//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CommonCrypto

public extension Data {
    var decrypted: Data? {
        Common.EncryptionManager.decrypt(secretData: self)
    }

    var encrypted: Data? {
        Common.EncryptionManager.encrypt(plainData: self)
    }
}

public extension String {
    var decrypted: String {
        Common.EncryptionManager.decrypt(base64EncodedSecret: self) ?? ""
    }

    var encrypted: String? {
        Common.EncryptionManager.encrypt(secret: self).base64Encoded
    }
}

public extension Common {
    enum EncryptionManager {
        public enum EncryptionError: Swift.Error {
            case encryptionError(status: CCCryptorStatus)
            case decryptionError(status: CCCryptorStatus)
            case keyDerivationError(status: CCCryptorStatus)
        }

        public static func encrypt(data: Data, key: Data, iv: Data) throws -> Data {
            // Output buffer (with padding)
            let outputLength = data.count + kCCBlockSizeAES128
            // swiftlint:disable syntactic_sugar
            var outputBuffer = Array<UInt8>(repeating: 0, count: outputLength)
            // swiftlint:enable syntactic_sugar
            var numBytesEncrypted = 0
            let status = CCCrypt(
                CCOperation(kCCEncrypt),
                CCAlgorithm(kCCAlgorithmAES),
                CCOptions(kCCOptionPKCS7Padding),
                Array(key),
                kCCKeySizeAES256,
                Array(iv),
                Array(data),
                data.count,
                &outputBuffer,
                outputLength,
                &numBytesEncrypted)
            guard status == kCCSuccess else {
                throw EncryptionError.encryptionError(status: status)
            }
            let outputBytes = iv + outputBuffer.prefix(numBytesEncrypted)
            return Data(outputBytes)
        }

        public static func decrypt(data cipherData: Data, key: Data) throws -> Data {
            guard cipherData.count >= iv.count else {
                return cipherData
            } // Invalid cipherData
            // Split IV and cipher text
            let iv = cipherData.prefix(kCCBlockSizeAES128)
            let cipherTextBytes = cipherData.suffix(from: kCCBlockSizeAES128)
            let cipherTextLength = cipherTextBytes.count
            // Output buffer
            // swiftlint:disable syntactic_sugar
            var outputBuffer = Array<UInt8>(
                repeating: 0,
                count: cipherTextLength)
            // swiftlint:enable syntactic_sugar
            var numBytesDecrypted = 0
            let status = CCCrypt(
                CCOperation(kCCDecrypt),
                CCAlgorithm(kCCAlgorithmAES),
                CCOptions(kCCOptionPKCS7Padding),
                Array(key),
                kCCKeySizeAES256,
                Array(iv),
                Array(cipherTextBytes),
                cipherTextLength,
                &outputBuffer,
                cipherTextLength,
                &numBytesDecrypted)
            guard status == kCCSuccess else {
                throw EncryptionError.decryptionError(status: status)
            }
            // Discard padding
            let outputBytes = outputBuffer.prefix(numBytesDecrypted)
            return Data(outputBytes)
        }

        public static func derivateKey(passphrase: String, salt: String) throws -> Data {
            let rounds = UInt32(45_000)
            // swiftlint:disable syntactic_sugar
            var outputBytes = Array<UInt8>(repeating: 0, count: kCCKeySizeAES256)
            // swiftlint:enable syntactic_sugar
            let status = CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                passphrase,
                passphrase.utf8.count,
                salt,
                salt.utf8.count,
                CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
                rounds,
                &outputBytes,
                kCCKeySizeAES256)

            guard status == kCCSuccess else {
                throw EncryptionError.keyDerivationError(status: status)
            }
            return Data(outputBytes)
        }

        @PWThreadSafe static var passphrase: String?
        @PWThreadSafe static var salt: String?

        public static var key: Data? {
            guard let defaultPassphrase = String(bytes: [38, 99, 51, 110, 99, 104, 35, 73, 120, 88, 36, 104, 57, 117, 35, 86].reversed(), encoding: .utf8),
                  let defaultSalt = String(bytes: [114, 104, 66, 110, 75, 38, 38, 48, 75, 112, 105, 87, 79, 83, 67, 108].reversed(), encoding: .utf8) else {
                return nil
            }
            if passphrase != nil {
                assert(passphrase!.count == defaultPassphrase.count)
            }
            if salt != nil {
                assert(salt!.count == defaultSalt.count)
            }
            let finalPassphrase = passphrase ?? defaultPassphrase
            let finalSalt = salt ?? defaultSalt
            return try? derivateKey(passphrase: finalPassphrase, salt: finalSalt)
        }

        public static var iv: Data {
            let randonString = String.random(16)
            let randonStringToByteArray: [UInt8] = Array(randonString.utf8)
            return Data(randonStringToByteArray)
            // return Data([14, 04, 166, 110, 175, 138, 138, 118, 175, 12, 05, 187, 179, 183, 167, 8].reversed())
        }

        public static func encrypt(plainData: Data?) -> Data? {
            guard let key, let plainData else {
                return nil
            }
            if let ciphered = try? encrypt(data: plainData, key: key, iv: iv) {
                return ciphered
            }
            return nil
        }

        public static func decrypt(secretData: Data?) -> Data? {
            guard let key, let secretData else {
                return nil
            }
            if let plainData = try? decrypt(data: secretData, key: key) {
                return plainData
            }
            return nil
        }

        public static func encrypt(secret: String?) -> (data: Data?, base64Encoded: String?) {
            guard let key, let secret else {
                return (nil, nil)
            }
            if let ciphered = try? encrypt(data: Data(secret.utf8), key: key, iv: iv) {
                return (data: ciphered, base64Encoded: ciphered.base64EncodedString())
            }
            return (nil, nil)
        }

        public static func decrypt(base64EncodedSecret: String?) -> String? {
            guard let key, let base64EncodedSecret else {
                return nil
            }
            if let input = Data(base64Encoded: base64EncodedSecret) {
                if let plainData = try? decrypt(data: input, key: key) {
                    return String(data: plainData, encoding: .utf8)
                }
            }
            return nil
        }

        public static func test(secret: String?) -> Bool {
            guard let key, let secret else {
                return false
            }
            let input = Data(secret.utf8)
            if let ciphertext = try? encrypt(data: input, key: key, iv: iv),
               let plain = try? decrypt(data: ciphertext, key: key) {
                let c1 = plain == input
                let c2 = String(data: plain, encoding: .utf8) == secret
                let encryptedString = encrypt(secret: secret)
                let decryptedString = decrypt(base64EncodedSecret: encryptedString.base64Encoded!)
                let c3 = decryptedString == secret
                let result = c1 && c2 && c3 // true
                return result
            }
            return false
        }
    }
}

extension StringProtocol {
    var data: Data { .init(utf8) }
    var bytes: [UInt8] { .init(utf8) }
}
