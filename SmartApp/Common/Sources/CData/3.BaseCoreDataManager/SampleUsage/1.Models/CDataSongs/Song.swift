//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation

//
// MARK: - Song
//

public extension CommonCoreData.Utils.Sample {
    struct Song: Equatable, Codable {
        public var title: String
        public var releaseDate: Date
        public var refSinger: CommonCoreData.Utils.Sample.Singer?
        public init(title: String,
                    releaseDate: Date,
                    singer: CommonCoreData.Utils.Sample.Singer?) {
            self.title = title
            self.releaseDate = releaseDate
            self.refSinger = singer
        }
    }
}

public extension CommonCoreData.Utils.Sample.Song {
    static var random: Self {
        Self(
            title: "Title \(String.randomWithSpaces(10))",
            releaseDate: Date.now, 
            singer: .random
        )
    }
}

