//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

//
// MARK: - ExpiringCodableObjectWithKey
//

public extension Common {
    class ExpiringKeyValueEntity: Codable {
        public private(set) var key: String! // Cache key (built using api request name and parameters)
        public private(set) var object: Data? // Value to be stored
        public private(set) var expireDate: Date! // The limit date in witch we can retried the object
        public private(set) var recordDate: Date!
        public private(set) var encoding: Int!
        public private(set) var objectType: String! // Value type to be stored (not needed for now)

        public convenience init(
            key: String,
            expireDate: Date,
            object: Data?,
            objectType: String,
            encoding: ValueEncoding = .dataPlain
        ) {
            self.init()
            self.key = key
            self.recordDate = Self.referenceDate
            self.expireDate = expireDate
            self.encoding = encoding.rawValue
            self.objectType = objectType
            self.object = Data()
            switch encoding {
            case .dataPlain:
                self.object = object
            case .dataAES:
                self.object = Common.EncryptionManager.encrypt(data: object, method: .default)
            }
        }

        public convenience init(
            key: String,
            params: [String],
            object: Data?,
            timeToLiveMinutes: Int? = nil,
            encoding: ValueEncoding = .dataPlain
        ) {
            self.init(
                key: Self.composedKey(key, params),
                expireDate: Self.ttlUsing(base: Self.referenceDate, with: timeToLiveMinutes ?? Self.defaultMinutesTTL),
                object: object,
                objectType: "\(String(describing: type(of: object)))",
                encoding: encoding
            )
        }

        public convenience init(
            _ codable: some Codable,
            key: String,
            params: [any Hashable] = [],
            timeToLiveMinutes: Int? = nil,
            encoding: ValueEncoding = .dataPlain
        ) {
            self.init(
                key: Self.composedKey(key, params),
                expireDate: Self.ttlUsing(base: Self.referenceDate, with: timeToLiveMinutes ?? Self.defaultMinutesTTL),
                object: try? JSONEncoder().encode(codable),
                objectType: "\(String(describing: type(of: codable)))",
                encoding: encoding
            )
        }
    }
}

//
// MARK: - Public
//

public extension Common.ExpiringKeyValueEntity {
    enum ValueEncoding: Int {
        case dataPlain = 0
        case dataAES
    }

    static var composedKeyPrefix: String {
        "\(Common.ExpiringKeyValueEntity.self)"
    }

    static func composedKey(_ key: String, _ keyParams: [any Hashable]) -> String {
        // let keyParams2 = keyParams.map { $0.hashValue.description }
        let keyParams2 = keyParams.map { "\($0)".sha1 }
        return "\(Self.composedKeyPrefix)_\(key)_[" + keyParams2.joined(separator: ",") + "]"
    }

    var isExpired: Bool { valueData == nil }

    func extract<T: Codable>(_ some: T.Type) -> T? {
        guard let data = valueData else {
            return nil
        }
        return try? JSONDecoder().decodeFriendly(T.self, from: data)
    }

    var valueData: Data? {
        guard Self.referenceDate < expireDate, let valueEncoding = ValueEncoding(rawValue: encoding) else {
            return nil
        }
        switch valueEncoding {
        case .dataPlain: return object
        case .dataAES: return Common.EncryptionManager.decrypt(data: object, method: .default)
        }
    }
}

//
// MARK: - fileprivate
//

fileprivate extension Common.ExpiringKeyValueEntity {
    var toData: Data? { try? JSONEncoder().encode(self) }
    static var referenceDate: Date { Date.utcNow }
    static var defaultMinutesTTL: Int { 60 * 24 }
    static func ttlUsing(base: Date, with ttl: Int?) -> Date {
        if let ttl {
            base.add(minutes: ttl)
        } else {
            base.add(minutes: defaultMinutesTTL)
        }
    }
}
