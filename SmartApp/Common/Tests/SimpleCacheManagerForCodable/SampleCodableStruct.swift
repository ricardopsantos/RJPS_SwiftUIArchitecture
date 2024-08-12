//
//  Created by Ricardo Santos on 12/08/2024.
//

import Foundation

struct SampleCodableStruct: Codable, Equatable {
    let name: String
    let age: Int
    let height: Double

    static var random: SampleCodableStruct {
        let randomName = UUID().uuidString
        let randomAge = Int.random(in: 18...40)
        let randomHeight = Double.random(in: 150...200)
        return SampleCodableStruct(name: randomName, age: randomAge, height: randomHeight)
    }
}
