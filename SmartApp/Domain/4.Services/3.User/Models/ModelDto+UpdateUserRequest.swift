//
//  UpdateUserRequest.swift
//  SmartApp
//
//  Created by Ashok Choudhary on 03/01/24.
//  Changed/Updated by Ricardo Santos on 15/04/2024.
//

import Foundation
//
import Domain
import Common

public extension ModelDto {
    struct UpdateUserRequest: ModelDtoProtocol {
        public let name: String?
        public let email: String
        public let password: String
        public let genderRawValue: String?
        public let dateOfBirth: Date?
        public let country: String?
        public let language: String?

        public var gender: Gender {
            Gender(rawValue: genderRawValue ?? "") ?? .other
        }

        public init(email: String, password: String) {
            self.email = email
            self.password = password
            self.name = nil
            self.dateOfBirth = nil
            self.genderRawValue = nil
            self.country = nil
            self.language = nil
        }

        public init(name: String, email: String, password: String, dateOfBirth: Date, gender: Gender, country: String, language: String) {
            self.email = email
            self.password = password
            self.name = name
            self.dateOfBirth = dateOfBirth
            self.genderRawValue = gender.rawValue
            self.country = country
            self.language = language
        }
    }
}
