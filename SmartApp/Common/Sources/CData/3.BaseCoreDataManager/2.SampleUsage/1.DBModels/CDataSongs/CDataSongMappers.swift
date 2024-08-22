//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation

//
// Mappers
//
public extension CDataSong {
    /// `cascade` to avoid dead lock on map (artists adding songs and songs adding back artists)
    func mapToModel(cascade: Bool) -> CommonCoreData.Utils.Sample.Song {
        .init(
            id: id ?? "",
            title: title ?? "",
            releaseDate: releaseDate ?? Date.now,
            cascadeSinger: cascade ? singer?.mapToModel : nil
        )
    }
}

public extension CommonCoreData.Utils.Sample.Song {
    var mapToDic: [String: Any] {
        [
            "releaseDate": releaseDate,
            "title": title,
            "id": id,
            "cascadeSinger": cascadeSinger ?? ""
        ]
    }
}
