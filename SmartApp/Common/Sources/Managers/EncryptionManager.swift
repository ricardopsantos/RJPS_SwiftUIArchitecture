//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

public extension StringProtocol {
    var data: Data { .init(utf8) }
    var bytes: [UInt8] { .init(utf8) }
}

public extension Data {
    var decrypted: Data? {
        Common.EncryptionManager.decrypt(data: self, method: .default)
    }

    var encrypted: Data? {
        Common.EncryptionManager.encrypt(data: self, method: .default)
    }
}

public extension String {
    var decrypted: String {
        Common.EncryptionManager.decrypt(base64String: self, method: .default) ?? ""
    }

    var encrypted: String? {
        Common.EncryptionManager.encrypt(string: self, method: .default).base64Encoded
    }
}

public extension Common {
    enum EncryptionManager {
        public enum Method {
            // AES-CBC with PKCS7: provides encryption with confidentiality
            // but requires additional measures for data integrity.
            case aesCBC
            // AES-GCM: offers both encryption and built-in integrity/authentication,
            // making it a more secure and efficient choice for modern applications.
            // GCM is generally preferred for its performance benefits and stronger security model.
            case aesGCM

            static var `default`: Self {
                .aesGCM
            }
        }

        public enum EncryptionError: Swift.Error {
            case encryptionError(status: CCCryptorStatus)
            case decryptionError(status: CCCryptorStatus)
            case keyDerivationError(status: CCCryptorStatus)
        }

        @PWThreadSafe static var passphraseAESCBC: String?
        @PWThreadSafe static var saltAESCBC: String?
        static var k: [UInt8] = [38, 99, 51, 110, 99, 104, 35, 73, 120, 88, 36, 104, 57, 117, 35, 86].reversed()

        public static func decrypt(data: Data?, method: Common.EncryptionManager.Method) -> Data? {
            switch method {
            case .aesCBC: decryptAESCBC(data: data)
            case .aesGCM: decryptAESGCM(data: data)
            }
        }

        public static func encrypt(data: Data?, method: Common.EncryptionManager.Method) -> Data? {
            switch method {
            case .aesCBC: encryptAESCBC(data: data)
            case .aesGCM: encryptAESGCM(data: data)
            }
        }

        public static func encrypt(string: String?, method: Common.EncryptionManager.Method) -> (
            data: Data?,

            base64Encoded: String?) {
            switch method {
            case .aesCBC: encryptAESCBC(string: string)
            case .aesGCM: encryptAESGCM(string: string)
            }
        }

        public static func decrypt(base64String: String?, method: Common.EncryptionManager.Method) -> String? {
            switch method {
            case .aesCBC: decryptAESCBC(base64String: base64String)
            case .aesGCM: decryptAESGMC(base64String: base64String)
            }
        }
    }
}

//
// MARK: - Sugar
//

fileprivate extension Common.EncryptionManager {
    //
    // Decrypt
    //
    static func decryptAESGCM(data: Data?) -> Data? {
        guard let keyAESGCM, let data else {
            return nil
        }
        return decryptAESGCM(data: data, key: keyAESGCM)
    }

    static func decryptAESGMC(base64String: String?) -> String? {
        guard let keyAESGCM, let base64String else {
            return nil
        }
        if let input = Data(base64Encoded: base64String) {
            if let plainData = decryptAESGCM(data: input, key: keyAESGCM) {
                return String(data: plainData, encoding: .utf8)
            }
        }
        return nil
    }

    static func decryptAESCBC(data: Data?) -> Data? {
        guard let keyAESCBC, let data else {
            return nil
        }
        if let plainData = try? decryptAESCBC(data: data, key: keyAESCBC) {
            return plainData
        }
        return nil
    }

    static func decryptAESCBC(base64String: String?) -> String? {
        guard let keyAESCBC, let base64String else {
            return nil
        }
        if let input = Data(base64Encoded: base64String) {
            if let plainData = try? decryptAESCBC(data: input, key: keyAESCBC) {
                return String(data: plainData, encoding: .utf8)
            }
        }
        return nil
    }

    static func decryptAESGCM(base64String: String?) -> String? {
        guard let keyAESGCM, let base64String else {
            return nil
        }
        if let input = Data(base64Encoded: base64String) {
            if let plainData = decryptAESGCM(data: input, key: keyAESGCM) {
                return String(data: plainData, encoding: .utf8)
            }
        }
        return nil
    }

    //
    // Encrypt
    //

    static func encryptAESGCM(data: Data?) -> Data? {
        guard let keyAESGCM, let data else {
            return nil
        }
        return encryptAESGCM(data: data, key: keyAESGCM)
    }

    static func encryptAESGCM(string: String?) -> (data: Data?, base64Encoded: String?) {
        guard let keyAESGCM, let string else {
            return (nil, nil)
        }
        if let ciphered = encryptAESGCM(data: Data(string.utf8), key: keyAESGCM) {
            return (data: ciphered, base64Encoded: ciphered.base64EncodedString())
        }
        return (nil, nil)
    }

    static func encryptAESCBC(data: Data?) -> Data? {
        guard let keyAESCBC, let data else {
            return nil
        }
        if let ciphered = try? encryptAESCBC(data: data, key: keyAESCBC, iv: ivAESCBC) {
            return ciphered
        }
        return nil
    }

    static func encryptAESCBC(string: String?) -> (data: Data?, base64Encoded: String?) {
        guard let keyAESCBC, let string else {
            return (nil, nil)
        }
        if let ciphered = try? encryptAESCBC(data: Data(string.utf8), key: keyAESCBC, iv: ivAESCBC) {
            return (data: ciphered, base64Encoded: ciphered.base64EncodedString())
        }
        return (nil, nil)
    }
}

//
// MARK: - Implementation (AES-CBC)
//

fileprivate extension Common.EncryptionManager {
    static var keyAESGCM: SymmetricKey? {
        SymmetricKey(data: k)
    }

    static func encryptAESGCM(data: Data, key: SymmetricKey) -> Data? {
        let sealedBox = try? AES.GCM.seal(data, using: key)
        return sealedBox?.combined
    }

    static func decryptAESGCM(data: Data, key: SymmetricKey) -> Data? {
        guard let sealedBox = try? AES.GCM.SealedBox(combined: data) else { return nil }
        return try? AES.GCM.open(sealedBox, using: key)
    }
}

//
// MARK: - Implementation (AES-CBC)
//

fileprivate extension Common.EncryptionManager {
    static var keyAESCBC: Data? {
        guard let defaultPassphrase = String(bytes: k.reversed(), encoding: .utf8),
              let defaultSalt = String(bytes: [114, 104, 66, 110, 75, 38, 38, 48, 75, 112, 105, 87, 79, 83, 67, 108].reversed(), encoding: .utf8) else {
            return nil
        }
        if passphraseAESCBC != nil {
            assert(passphraseAESCBC!.count == defaultPassphrase.count)
        }
        if saltAESCBC != nil {
            assert(saltAESCBC!.count == defaultSalt.count)
        }
        let finalPassphrase = passphraseAESCBC ?? defaultPassphrase
        let finalSalt = saltAESCBC ?? defaultSalt
        return try? derivateKeyAESCBC(passphrase: finalPassphrase, salt: finalSalt)
    }

    static var ivAESCBC: Data {
        let randonString = String.random(16)
        let randonStringToByteArray: [UInt8] = Array(randonString.utf8)
        return Data(randonStringToByteArray)
        // return Data([14, 04, 166, 110, 175, 138, 138, 118, 175, 12, 05, 187, 179, 183, 167, 8].reversed())
    }

    static func encryptAESCBC(data: Data, key: Data, iv: Data) throws -> Data {
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

    static func decryptAESCBC(data cipherData: Data, key: Data) throws -> Data {
        guard cipherData.count >= ivAESCBC.count else {
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

    static func derivateKeyAESCBC(passphrase: String, salt: String) throws -> Data {
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
}
