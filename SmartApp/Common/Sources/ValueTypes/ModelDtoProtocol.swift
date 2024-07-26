//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

/// Encapsulate all Data Transaction Objects (API Request and responses)
public struct ModelDto {
    private init() {}
}

// By inheriting the CustomStringConvertible protocol, we need to provide a value to the description property.
// Every time, we want to use the object as a String, the program will refer to the description property.
// Now we can manage our message in one place :)

public protocol ModelDtoProtocol: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {}

extension String: ModelDtoProtocol {}

extension Array<String>: ModelDtoProtocol {
    public var description: String {
        // Customize the description of your array here
        "[" + joined(separator: ", ") + "]"
    }

    // Implement Codable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Element] = []

        while !container.isAtEnd {
            let element = try container.decode(Element.self)
            elements.append(element)
        }

        self = elements
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try container.encode(element)
        }
    }

    // Implement Equatable

    // swiftlint:disable syntactic_sugar
    public static func == (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
        lhs.elementsEqual(rhs)
    }

    // swiftlint:enable syntactic_sugar

    // Implement Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }

    // Implement Sendable (assuming Sendable has no additional requirements)
    // If Sendable has specific requirements, implement them accordingly

    // Implement CustomStringConvertible
    public var customDescription: String {
        description
    }
}

/**

  Sample Request

  ```
  public extension ModelDto {
      struct WeatherRequest: ModelDtoProtocol {
          public let latitude: String
          public let longitude: String
          public init(latitude: String, longitude: String) {
              self.longitude = longitude
              self.latitude = latitude
          }
      }
  }
 ```

  Sample Response

  ```
  public extension ModelDto {
      struct WeatherResponse: ModelDtoProtocol {
          public var latitude, longitude, generationtimeMS: Double?

          public init() {}

          enum CodingKeys: String, CodingKey {
              case latitude
              case longitude
              case generationtimeMS = "generationtime_ms"
          }
      }
  ```
  */
