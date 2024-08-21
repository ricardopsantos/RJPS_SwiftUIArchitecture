//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation

//
// MARK: - Song
//

public extension CommonCoreData.Utils.Sample {
    struct Song: Equatable, Codable {
        public var id: String
        public var title: String
        public var releaseDate: Date
        public var cascadeSinger: CommonCoreData.Utils.Sample.Singer?
        public init(id: String, title: String,
                    releaseDate: Date,
                    cascadeSinger: CommonCoreData.Utils.Sample.Singer?) {
            self.id = id
            self.title = title
            self.releaseDate = releaseDate
            self.cascadeSinger = cascadeSinger
        }
    }
}

public extension CommonCoreData.Utils.Sample.Song {
    static var random: Self {
        Self(
            id: UUID().uuidString,
            title: "Title \(String.randomWithSpaces(10))",
            releaseDate: Date.now,
            cascadeSinger: .random
        )
    }
}

