//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

// To encapsulate all RequestDto's (used on web api requests)
public struct RequestDto {
    private init() {}
}

// By inheriting the CustomStringConvertible protocol, we need to provide a value to the description property.
// Every time, we want to use the object as a String, the program will refer to the description property.
// Now we can manage our message in one place :)

public protocol RequestDtoProtocol: Codable, Hashable, CustomStringConvertible {}
