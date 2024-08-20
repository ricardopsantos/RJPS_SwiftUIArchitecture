//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation

//
// MARK: - Singer
//
public extension CommonCoreData.Utils.Sample {
    struct Singer: Equatable, Codable {
        public var name: String
        public var refSongs: [CommonCoreData.Utils.Sample.Song]?
        public init(name: String, songs: [CommonCoreData.Utils.Sample.Song]) {
            self.name = name
            self.refSongs = songs
        }
    }
}

public extension CommonCoreData.Utils.Sample.Singer {
    static var random: Self {
        Self(
            name: "Joe \(String.randomWithSpaces(10))", 
            songs: [.random, .random]
        )
    }
}
