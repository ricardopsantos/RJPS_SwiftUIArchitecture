//
//  StateRequest.swift
//  Domain
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
//
import Common

public extension ModelDto {
    struct NationRequest: ModelDtoProtocol {
        public let drilldowns: String
        public let measures: String
        public let year: String
        public init(drilldowns: String = "State", measures: String = "Population", year: String = "latest") {
            self.drilldowns = drilldowns
            self.measures = measures
            self.year = year
        }
    }
}
