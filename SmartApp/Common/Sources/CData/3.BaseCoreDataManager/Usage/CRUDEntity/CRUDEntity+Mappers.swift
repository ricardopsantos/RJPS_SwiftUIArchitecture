//
//  Created by Ricardo Santos on 14/08/2024.
//

import Foundation

//
// Mappers
//
public extension CDataCRUDEntity {
    var mapToModel: CommonCoreData.Utils.Sample.CRUDEntity? {
        .init(id: id ?? "", name: name ?? "", recordDate: recordDate ?? .now)
    }
}

public extension CommonCoreData.Utils.Sample.CRUDEntity {
    var mapToDic: [String: Any] {
        [
            "id": id,
            "name": name,
            "recordDate": recordDate
        ]
    }
}
