//
//  UpdateUserResponse.swift
//  SmartApp
//
//  Created by Ashok Choudhary on 03/01/24.
//  Changed/Updated by Ricardo Santos on 15/04/2024.
//

import Foundation
import Common

public extension ModelDto {
    struct UpdateUserResponse: ModelDtoProtocol {
        let name: String?
        let email: String
        let password: String
        let gender: String?
        let dob: String?
        let country: String?

        init(email: String, password: String) {
            self.email = email
            self.password = password
            self.name = nil
            self.dob = nil
            self.gender = nil
            self.country = nil
        }

        init(name: String, email: String, password: String, dob: String, gender: String, country: String, language: String) {
            self.email = email
            self.password = password
            self.name = name
            self.dob = dob
            self.gender = gender
            self.country = country
        }
    }
}
