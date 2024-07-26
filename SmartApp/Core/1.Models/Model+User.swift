//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Common

public extension Model {
    struct User: ModelDtoProtocol {
        public let name: String?
        public var email: String
        public var password: String
        public let gender: String?
        public var dateOfBirth: Date?
        public let country: String?

        public init(email: String, password: String) {
            self.email = email
            self.password = password
            self.name = nil
            self.dateOfBirth = nil
            self.gender = nil
            self.country = nil
        }

        public init(name: String, email: String, password: String, dateOfBirth: Date, gender: String, country: String) {
            self.email = email
            self.password = password
            self.name = name
            self.dateOfBirth = dateOfBirth
            self.gender = gender
            self.country = country
        }
    }
}
