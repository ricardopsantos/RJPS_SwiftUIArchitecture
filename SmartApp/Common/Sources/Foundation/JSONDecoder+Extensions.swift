//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension Common {
    struct WrapEncodable<T: Encodable>: Encodable {
        public let t: T
        public init(t: T) {
            self.t = t
        }
    }

    struct WrapDecodable<T: Decodable>: Decodable {
        public let t: T
        public init(t: T) {
            self.t = t
        }
    }

    enum JSONDecoderErrors: Error {
        case decodeFail
    }

    func perfectMapperThrows<B: Decodable>(inValue: some Encodable, outValue: B.Type) throws -> B {
        do {
            let encoded = try JSONEncoder().encode(inValue)
            let decoded = try JSONDecoder().decodeFriendly(B.self, from: encoded)
            return decoded
        } catch {
            throw error
        }
    }

    func perfectMapper<B: Decodable>(inValue: some Encodable, outValue: B.Type) -> B? {
        do {
            return try perfectMapperThrows(inValue: inValue, outValue: outValue)
        } catch {
            return nil
        }
    }
}

//
// MARK: - Safe decoder
//

public extension JSONDecoder {
    static var defaultForWebAPI: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }

    // Decoder that when fails log as much information as possible for a fast correction/debug
    // swiftlint:disable function_body_length
    func decodeFriendly<T: Decodable>(_ type: T.Type, from data: Data, printError: Bool = true) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            var debugMessage = "# Fail decoding data into [\(type)]"
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case DecodingError.dataCorrupted(let context):
                    debugMessage = """
                    \(debugMessage)
                    # error = DecodingError.dataCorrupted
                    # context = \(context.debugDescription)
                    # context.codingPath = \(context.codingPath.debugDescription)
                    """
                case DecodingError.keyNotFound(let codingKey, let context):
                    debugMessage = """
                    \(debugMessage)
                    # DecodingError = .keyNotFound
                    # codingKey = \(codingKey.debugDescription)
                    # context = \(context.debugDescription)
                    # context.codingPath = \(context.codingPath.debugDescription)
                    """
                case DecodingError.typeMismatch(let propertyType, let context):
                    debugMessage = """
                    \(debugMessage)
                    # DecodingError = .typeMismatch
                    # type = \(String(describing: propertyType.self))
                    # context = \(context.debugDescription)
                    # context.codingPath = \(context.codingPath)
                    """
                case DecodingError.valueNotFound(let propertyType, let context):
                    debugMessage = """
                    \(debugMessage)
                    # DecodingError = .valueNotFound
                    # type = \(String(describing: propertyType.self))
                    # context = \(context.debugDescription)
                    # context.codingPathList = \(context.codingPath.debugDescription)
                    """
                default:
                    break
                }
            }

            if let object = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let json = object as? [String: Any] {
                    debugMessage = "\(debugMessage)# Data contains a single object\n"
                    debugMessage = "\(debugMessage)# \(json)\n"
                } else if let jsonArray = object as? [[String: Any]] {
                    debugMessage = "\(debugMessage)# Data contains an array\n"
                    debugMessage = "\(debugMessage)# \(jsonArray.prefix(5))\n"
                } else {
                    debugMessage = "\(debugMessage)\n# Not predicted"
                }
            } else {
                debugMessage = "\(debugMessage)\n# Data does not look JSON"
                debugMessage = "\(debugMessage)\n# \(String(decoding: data, as: UTF8.self))"
            }

            debugMessage = "\(debugMessage)\n# \(error.localizedDescription)"
            debugMessage = "\(debugMessage)\n# \(error)"
            if printError {
                Common.LogsManager.error("\(debugMessage)")
            }
            throw error
        }
    }

    // swiftlint:enable function_body_length

    private func decodeSafe<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        // https://bugs.swift.org/browse/SR-6163 - Encode/Decode not possible < iOS 13 for top-level fragments (enum, int, string, etc.).
        if #available(iOS 13.0, *) {
            return try JSONDecoder().decodeFriendly(type, from: data)
        } else {}
    }
}
