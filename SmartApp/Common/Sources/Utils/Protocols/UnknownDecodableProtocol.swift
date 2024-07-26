//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public protocol UnknownDecodableProtocol: Decodable, RawRepresentable {
    static var unknown: Self { get }
}

extension UnknownDecodableProtocol where RawValue: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(RawValue.self)
        self = Self(rawValue: raw) ?? .unknown
    }
}

//
// MARK: - Usage
//
enum UnknownDecodableProtocol_SampleEnum1: Int, UnknownDecodableProtocol {
    case active = 1
    case inactive = 0
    case unknown = -1
}

public func unknownDecodableProtocol_sampleUsage() {
    let jsonForSampleEnum1 = "1"
    let jsonForSampleEnum2 = "100"

    let decoder = JSONDecoder()
    let resultJSON1 = try? decoder.decode(
        UnknownDecodableProtocol_SampleEnum1.self,
        from: jsonForSampleEnum1.data(using: .utf8)!
    )
    let resultJSON2 = try? decoder.decode(
        UnknownDecodableProtocol_SampleEnum1.self,
        from: jsonForSampleEnum2.data(using: .utf8)!
    )
    Common_Utils.assert(resultJSON1 == .active)
    Common_Utils.assert(resultJSON2 == .unknown)
}
