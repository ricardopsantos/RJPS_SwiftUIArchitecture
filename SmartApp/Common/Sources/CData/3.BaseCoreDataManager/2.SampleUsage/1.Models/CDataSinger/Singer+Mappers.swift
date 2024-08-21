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
        return .init(id: id ?? "",
                     name: name ?? "",
                     cascadeSongs: artistSongs.map({ $0.mapToModel(cascade: false) }))
    }
}

public extension CommonCoreData.Utils.Sample.Singer {
    var mapToDic: [String: Any] {
        [
            "id": id,
            "cascadeSongs": cascadeSongs ?? "",
            "name": name,
        ]
    }
}
