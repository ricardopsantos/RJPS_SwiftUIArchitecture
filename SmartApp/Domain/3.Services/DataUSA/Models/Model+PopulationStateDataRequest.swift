//
//  PopulationStateDataRequest.swift
//  Domain
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
//
import Common

public extension ModelDto.PopulationStateDataRequest {
    struct Constants {
        public static let lastYear = "latest"
    }
}

public extension ModelDto {
    struct PopulationStateDataRequest: ModelDtoProtocol {
        public let drilldowns: String
        public let measures: String
        public let year: String
        public init(
            drilldowns: String = "State",
            measures: String = "Population",
            year: String = ModelDto.PopulationStateDataRequest.Constants.lastYear
        ) {
            self.drilldowns = drilldowns
            self.measures = measures
            self.year = year.intValue ?? 0 > 0 ? year : ModelDto.PopulationStateDataRequest.Constants.lastYear
        }
    }
}
