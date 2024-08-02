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
        let data: [Datum]
        let source: [Source]
        
        
        // MARK: - Datum
        struct Datum: ModelProtocol {
            let idNation: IDNation
            let nation: Nation
            let idYear: Int
            let year: String
            let population: Int
            let slugNation: SlugNation

            enum CodingKeys: String, CodingKey {
                case idNation = "ID Nation"
                case nation = "Nation"
                case idYear = "ID Year"
                case year = "Year"
                case population = "Population"
                case slugNation = "Slug Nation"
            }
        }

        enum IDNation: String, ModelProtocol {
            case the01000Us = "01000US"
        }

        enum Nation: String, ModelProtocol {
            case unitedStates = "United States"
        }

        enum SlugNation: String, ModelProtocol {
            case unitedStates = "united-states"
        }

        // MARK: - Source
        struct Source: ModelProtocol {
            let measures: [String]
            let annotations: Annotations
            let name: String
            //let substitutions: [JSONAny]
        }

        // MARK: - Annotations
        struct Annotations: ModelProtocol {
            let sourceName, sourceDescription, datasetName: String
            let datasetLink: String
            let tableID, topic, subtopic: String

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
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 331097593,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2021,
                    "Year": "2021",
                    "Population": 329725481,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2020,
                    "Year": "2020",
                    "Population": 326569308,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2019,
                    "Year": "2019",
                    "Population": 324697795,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2018,
                    "Year": "2018",
                    "Population": 322903030,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2017,
                    "Year": "2017",
                    "Population": 321004407,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2016,
                    "Year": "2016",
                    "Population": 318558162,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2015,
                    "Year": "2015",
                    "Population": 316515021,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2014,
                    "Year": "2014",
                    "Population": 314107084,
                    "Slug Nation": "united-states"
                },
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2013,
                    "Year": "2013",
                    "Population": 311536594,
                    "Slug Nation": "united-states"
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
