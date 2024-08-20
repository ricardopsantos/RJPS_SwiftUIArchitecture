//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation

//
// Mappers
//
public extension CDataSinger {
    var mapToModel: CommonCoreData.Utils.Sample.Singer {
        var artistSongs: [CDataSong] = []
        if let some = songs?.allObjects as? [CDataSong] {
            artistSongs = some
        }
        return .init(name: name ?? "", 
                     songs: artistSongs.map({ $0.mapToModel(includeRelations: false) }))
    }
}

public extension CommonCoreData.Utils.Sample.Singer {
    var mapToDic: [String: Any] {
        [
            "name": name,
        ]
    }
}
