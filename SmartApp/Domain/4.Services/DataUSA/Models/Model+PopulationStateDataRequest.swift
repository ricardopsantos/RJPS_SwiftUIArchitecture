//
//  PopulationStateDataRequest.swift
//  Domain
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
//
import Common

public extension ModelDto {
    struct PopulationStateDataRequest: ModelDtoProtocol {
        public let drilldowns: String
        public let measures: String
        public init(drilldowns: String = "Nation", measures: String = "Population") {
            self.drilldowns = drilldowns
            self.measures = measures
        }
    }
}
