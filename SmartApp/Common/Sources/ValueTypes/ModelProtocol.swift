//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

// To encapsulate all Model's (used on views)
public struct Model {
    private init() {}
}

public protocol ModelTwinProtocol {
    var twinClassName: String { get } // The name of the twin class
}

public protocol ModelProtocol: Codable, Hashable, CustomStringConvertible {}

public protocol ModelForViewProtocol: ModelProtocol, Equatable, Identifiable {}

// By inheriting the CustomStringConvertible protocol, we need to provide a value to the description property.
// Every time, we want to use the object as a String, the program will refer to the description property.
// Now we can manage our message in one place :)

/**
  __Fast compliance__
 ```
 init?(rawValue: String?) { fatalError() }
 public init(from decoder: Decoder) throws { fatalError() }
 public func encode(to encoder: Encoder) throws { fatalError() }
 static public func ==(lhs: AccountTiles, rhs: AccountTiles) -> Bool { fatalError() }
 public func hash(into hasher: inout Hasher) { fatalError() }
 ```
 */
