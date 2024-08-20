//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation

//
// Mappers
//
public extension CDataSong {
    
    /// `includeRelations` to avoid dead lock on map (artists adding songs and songs adding back artists)
    func mapToModel(includeRelations: Bool) -> CommonCoreData.Utils.Sample.Song {
        return .init(title: title ?? "",
                     releaseDate: releaseDate ?? Date.now,
                     singer: includeRelations ? singer?.mapToModel : nil)
    }
}

public extension CommonCoreData.Utils.Sample.Song {
    var mapToDic: [String: Any] {
        [
            "releaseDate": releaseDate,
            "title": title,
        ]
    }
}
