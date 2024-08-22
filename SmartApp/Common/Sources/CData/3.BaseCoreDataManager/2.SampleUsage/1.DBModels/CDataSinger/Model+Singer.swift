//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation

//
// MARK: - Singer
//
public extension CommonCoreData.Utils.Sample {
    struct Singer: Equatable, Codable {
        public var id: String
        public var name: String
        public var cascadeSongs: [CommonCoreData.Utils.Sample.Song]?
        public init(id: String, name: String, cascadeSongs: [CommonCoreData.Utils.Sample.Song]) {
            self.id = id
            self.name = name
            self.cascadeSongs = cascadeSongs
        }
    }
}

public extension CommonCoreData.Utils.Sample.Singer {
    static var random: Self {
        Self(
            id: UUID().uuidString,
            name: "Joe \(String.randomWithSpaces(10))",
            cascadeSongs: [.random, .random]
        )
    }
}
