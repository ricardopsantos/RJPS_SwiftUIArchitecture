//
//  PopulationStateDataResponse.swift
//  Domain
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
//
import Common

public extension ModelDto {
    // MARK: - PopulationStateDataResponse
    struct PopulationStateDataResponse: ModelProtocol {
        public let data: [Datum]
        public let source: [Source]

        // MARK: - Datum
        public struct Datum: ModelProtocol {
            public let idState, state: String
            public let idYear: Int
            public let year: String
            public let population: Int
            public let slugState: String

            enum CodingKeys: String, CodingKey {
                case idState = "ID State"
                case state = "State"
                case idYear = "ID Year"
                case year = "Year"
                case population = "Population"
                case slugState = "Slug State"
            }
        }

        // MARK: - Source
        public struct Source: ModelProtocol {
            public let measures: [String]
            public let annotations: Annotations
            public let name: String
            // let substitutions: [JSONAny]
        }

        // MARK: - Annotations
        public struct Annotations: ModelProtocol {
            public let sourceName, sourceDescription, datasetName: String
            public let datasetLink: String
            public let tableID, topic, subtopic: String

            enum CodingKeys: String, CodingKey {
                case sourceName = "source_name"
                case sourceDescription = "source_description"
                case datasetName = "dataset_name"
                case datasetLink = "dataset_link"
                case tableID = "table_id"
                case topic, subtopic
            }
        }
    }
}

public extension ModelDto.PopulationStateDataResponse {
    // swiftlint:disable line_length
    static var mock: Self? {
        let jsonString = """
        {
            "data": [
                {
                    "ID State": "04000US01",
                    "State": "Alabama",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 5028092,
                    "Slug State": "alabama"
                },
                {
                    "ID State": "04000US02",
                    "State": "Alaska",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 734821,
                    "Slug State": "alaska"
                },
                {
                    "ID State": "04000US04",
                    "State": "Arizona",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 7172282,
                    "Slug State": "arizona"
                },
                {
                    "ID State": "04000US05",
                    "State": "Arkansas",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 3018669,
                    "Slug State": "arkansas"
                },
                {
                    "ID State": "04000US06",
                    "State": "California",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 39356104,
                    "Slug State": "california"
                },
                {
                    "ID State": "04000US08",
                    "State": "Colorado",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 5770790,
                    "Slug State": "colorado"
                },
                {
                    "ID State": "04000US09",
                    "State": "Connecticut",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 3611317,
                    "Slug State": "connecticut"
                },
                {
                    "ID State": "04000US10",
                    "State": "Delaware",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 993635,
                    "Slug State": "delaware"
                },
                {
                    "ID State": "04000US11",
                    "State": "District of Columbia",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 670587,
                    "Slug State": "district-of-columbia"
                },
                {
                    "ID State": "04000US12",
                    "State": "Florida",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 21634529,
                    "Slug State": "florida"
                },
                {
                    "ID State": "04000US13",
                    "State": "Georgia",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 10722325,
                    "Slug State": "georgia"
                },
                {
                    "ID State": "04000US15",
                    "State": "Hawaii",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 1450589,
                    "Slug State": "hawaii"
                },
                {
                    "ID State": "04000US16",
                    "State": "Idaho",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 1854109,
                    "Slug State": "idaho"
                },
                {
                    "ID State": "04000US17",
                    "State": "Illinois",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 12757634,
                    "Slug State": "illinois"
                },
                {
                    "ID State": "04000US18",
                    "State": "Indiana",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 6784403,
                    "Slug State": "indiana"
                },
                {
                    "ID State": "04000US19",
                    "State": "Iowa",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 3188836,
                    "Slug State": "iowa"
                },
                {
                    "ID State": "04000US20",
                    "State": "Kansas",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 2935922,
                    "Slug State": "kansas"
                },
                {
                    "ID State": "04000US21",
                    "State": "Kentucky",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 4502935,
                    "Slug State": "kentucky"
                },
                {
                    "ID State": "04000US22",
                    "State": "Louisiana",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 4640546,
                    "Slug State": "louisiana"
                },
                {
                    "ID State": "04000US23",
                    "State": "Maine",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 1366949,
                    "Slug State": "maine"
                },
                {
                    "ID State": "04000US24",
                    "State": "Maryland",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 6161707,
                    "Slug State": "maryland"
                },
                {
                    "ID State": "04000US25",
                    "State": "Massachusetts",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 6984205,
                    "Slug State": "massachusetts"
                },
                {
                    "ID State": "04000US26",
                    "State": "Michigan",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 10057921,
                    "Slug State": "michigan"
                },
                {
                    "ID State": "04000US27",
                    "State": "Minnesota",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 5695292,
                    "Slug State": "minnesota"
                },
                {
                    "ID State": "04000US28",
                    "State": "Mississippi",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 2958846,
                    "Slug State": "mississippi"
                },
                {
                    "ID State": "04000US29",
                    "State": "Missouri",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 6154422,
                    "Slug State": "missouri"
                },
                {
                    "ID State": "04000US30",
                    "State": "Montana",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 1091840,
                    "Slug State": "montana"
                },
                {
                    "ID State": "04000US31",
                    "State": "Nebraska",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 1958939,
                    "Slug State": "nebraska"
                },
                {
                    "ID State": "04000US32",
                    "State": "Nevada",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 3104817,
                    "Slug State": "nevada"
                },
                {
                    "ID State": "04000US33",
                    "State": "New Hampshire",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 1379610,
                    "Slug State": "new-hampshire"
                },
                {
                    "ID State": "04000US34",
                    "State": "New Jersey",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 9249063,
                    "Slug State": "new-jersey"
                },
                {
                    "ID State": "04000US35",
                    "State": "New Mexico",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 2112463,
                    "Slug State": "new-mexico"
                },
                {
                    "ID State": "04000US36",
                    "State": "New York",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 19994379,
                    "Slug State": "new-york"
                },
                {
                    "ID State": "04000US37",
                    "State": "North Carolina",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 10470214,
                    "Slug State": "north-carolina"
                },
                {
                    "ID State": "04000US38",
                    "State": "North Dakota",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 776874,
                    "Slug State": "north-dakota"
                },
                {
                    "ID State": "04000US39",
                    "State": "Ohio",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 11774683,
                    "Slug State": "ohio"
                },
                {
                    "ID State": "04000US40",
                    "State": "Oklahoma",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 3970497,
                    "Slug State": "oklahoma"
                },
                {
                    "ID State": "04000US41",
                    "State": "Oregon",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 4229374,
                    "Slug State": "oregon"
                },
                {
                    "ID State": "04000US42",
                    "State": "Pennsylvania",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 12989208,
                    "Slug State": "pennsylvania"
                },
                {
                    "ID State": "04000US44",
                    "State": "Rhode Island",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 1094250,
                    "Slug State": "rhode-island"
                },
                {
                    "ID State": "04000US45",
                    "State": "South Carolina",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 5142750,
                    "Slug State": "south-carolina"
                },
                {
                    "ID State": "04000US46",
                    "State": "South Dakota",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 890342,
                    "Slug State": "south-dakota"
                },
                {
                    "ID State": "04000US47",
                    "State": "Tennessee",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 6923772,
                    "Slug State": "tennessee"
                },
                {
                    "ID State": "04000US48",
                    "State": "Texas",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 29243342,
                    "Slug State": "texas"
                },
                {
                    "ID State": "04000US49",
                    "State": "Utah",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 3283809,
                    "Slug State": "utah"
                },
                {
                    "ID State": "04000US50",
                    "State": "Vermont",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 643816,
                    "Slug State": "vermont"
                },
                {
                    "ID State": "04000US51",
                    "State": "Virginia",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 8624511,
                    "Slug State": "virginia"
                },
                {
                    "ID State": "04000US53",
                    "State": "Washington",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 7688549,
                    "Slug State": "washington"
                },
                {
                    "ID State": "04000US54",
                    "State": "West Virginia",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 1792967,
                    "Slug State": "west-virginia"
                },
                {
                    "ID State": "04000US55",
                    "State": "Wisconsin",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 5882128,
                    "Slug State": "wisconsin"
                },
                {
                    "ID State": "04000US56",
                    "State": "Wyoming",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 577929,
                    "Slug State": "wyoming"
                },
                {
                    "ID State": "04000US72",
                    "State": "Puerto Rico",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 3272382,
                    "Slug State": "puerto-rico"
                }
            ],
            "source": [
                {
                    "measures": [
                        "Population"
                    ],
                    "annotations": {
                        "source_name": "Census Bureau",
                        "source_description": "The American Community Survey (ACS) is conducted by the US Census and sent to a portion of the population every year.",
                        "dataset_name": "ACS 5-year Estimate",
                        "dataset_link": "http://www.census.gov/programs-surveys/acs/",
                        "table_id": "B01003",
                        "topic": "Diversity",
                        "subtopic": "Demographics"
                    },
                    "name": "acs_yg_total_population_5",
                    "substitutions": []
                }
            ]
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        return try? JSONDecoder().decode(Self.self, from: jsonData)
        // swiftlint:enable line_length
    }
}
