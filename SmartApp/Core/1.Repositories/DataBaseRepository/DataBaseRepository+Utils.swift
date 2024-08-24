//
//  DataBaseRepository.swift
//  Core
//
//  Created by Ricardo Santos on 21/08/2024.
//

import Foundation
//
import Common
import CoreData

public extension DataBaseRepository {
    func initDataBase() {
        if trackedLogGetAll(cascade: false).isEmpty {
            let coffeeEvents: [Model.TrackedLog] = [
                .init(
                    latitude: 47.6097,
                    longitude: -122.3331,
                    addressMin: "Starbucks, Seattle, WA",
                    note: "Starbucks",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 43.6532,
                    longitude: -79.3832,
                    addressMin: "Tim Hortons, Toronto, ON",
                    note: "Tim Hortons",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 42.3601,
                    longitude: -71.0589,
                    addressMin: "Dunkin', Boston, MA",
                    note: "Dunkin",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 51.5074,
                    longitude: -0.1278,
                    addressMin: "Costa Coffee, London, UK",
                    note: "Costa Coffee",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 34.0522,
                    longitude: -118.2437,
                    addressMin: "The Coffee Bean & Tea Leaf, Los Angeles, CA",
                    note: "The Coffee Bean & Tea Leaf",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                )
            ]
            let coffee: Model.TrackedEntity = .init(
                id: UUID().uuidString,
                name: "Coffee",
                info: "To track the amount of coffee I drink",
                archived: false,
                favorite: true,
                locationRelevant: true,
                category: .cultural,
                sound: .boo1,
                cascadeEvents: coffeeEvents
            )

            let gymnasiumEvents: [Model.TrackedLog] = [
                .init(
                    latitude: 52.5200,
                    longitude: 13.4050,
                    addressMin: "Holmes Place, Berlin, Germany",
                    note: "Holmes Place",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 40.7128,
                    longitude: -74.0060,
                    addressMin: "Central Park, New York, NY",
                    note: "Outdoor",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 52.5200,
                    longitude: 13.4050,
                    addressMin: "Holmes Place, Berlin, Germany",
                    note: "Holmes Place",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 40.7128,
                    longitude: -74.0060,
                    addressMin: "Central Park, New York, NY",
                    note: "Outdoor",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 40.7128,
                    longitude: -74.0060,
                    addressMin: "Central Park, New York, NY",
                    note: "Outdoor",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                )
            ]
            let gymnasium: Model.TrackedEntity = .init(
                id: UUID().uuidString,
                name: "Gymnasium",
                info: "",
                archived: false,
                favorite: false,
                locationRelevant: true,
                category: .health,
                sound: .cheer1,
                cascadeEvents: gymnasiumEvents
            )

            let cinemaEvents: [Model.TrackedLog] = [
                .init(
                    latitude: 34.0522,
                    longitude: -118.2437,
                    addressMin: "AMC Theatres, Los Angeles, CA",
                    note: "Avengers: Endgame",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 33.7675,
                    longitude: -84.4207,
                    addressMin: "Regal Cinemas, Atlanta, GA",
                    note: "Jurassic World",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 40.7128,
                    longitude: -74.0060,
                    addressMin: "AMC Empire 25, New York, NY",
                    note: "The Dark Knight",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: -37.8136,
                    longitude: 144.9631,
                    addressMin: "Hoyts Cinema, Melbourne, Australia",
                    note: "Avatar",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 51.5074,
                    longitude: -0.1278,
                    addressMin: "Odeon Cinema, London, UK",
                    note: "Inception",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 35.6895,
                    longitude: 139.6917,
                    addressMin: "TOHO Cinemas, Tokyo, Japan",
                    note: "Black Panther",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 34.0522,
                    longitude: -118.2437,
                    addressMin: "AMC Theatres, Los Angeles, CA",
                    note: "Star Wars: The Force Awakens",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                )
            ]

            let cinema: Model.TrackedEntity = .init(
                id: UUID().uuidString,
                name: "Cinema",
                info: "",
                archived: false,
                favorite: false,
                locationRelevant: true,
                category: .cultural,
                sound: .cheer1,
                cascadeEvents: cinemaEvents
            )

            let chessEvents: [Model.TrackedLog] = [
                .init(
                    latitude: 52.3740,
                    longitude: 4.8897,
                    addressMin: "Wijk aan Zee, Netherlands",
                    note: "Tata Steel Chess Tournament",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 55.7558,
                    longitude: 37.6176,
                    addressMin: "Moscow, Russia",
                    note: "Candidates Tournament",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 38.6270,
                    longitude: -90.1994,
                    addressMin: "St. Louis, MO",
                    note: "Sinquefield Cup",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                )
            ]

            let chess: Model.TrackedEntity = .init(
                id: UUID().uuidString,
                name: "Chess Tournaments",
                info: "",
                archived: false,
                favorite: false,
                locationRelevant: true,
                category: .personal,
                sound: .cheer1,
                cascadeEvents: chessEvents
            )

            let concertEvents: [Model.TrackedLog] = [
                .init(
                    latitude: 51.5074,
                    longitude: -0.1278,
                    addressMin: "Wembley Stadium, London, UK",
                    note: "Coldplay Live",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 40.7505,
                    longitude: -73.9934,
                    addressMin: "Madison Square Garden, New York, NY",
                    note: "Beyoncé Concert",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 51.5074,
                    longitude: -0.1278,
                    addressMin: "Wembley Stadium, London, UK",
                    note: "Ed Sheeran Tour",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 34.0522,
                    longitude: -118.2437,
                    addressMin: "Rose Bowl, Los Angeles, CA",
                    note: "Taylor Swift Concert",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 43.6532,
                    longitude: -79.3832,
                    addressMin: "Rogers Centre, Toronto, ON",
                    note: "The Weeknd Live",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                )
            ]

            let concerts: Model.TrackedEntity = .init(
                id: UUID().uuidString,
                name: "Concerts",
                info: "",
                archived: false,
                favorite: true,
                locationRelevant: true,
                category: .cultural,
                sound: .cheer1,
                cascadeEvents: concertEvents
            )

            let bookEvents: [Model.TrackedLog] = [
                .init(
                    latitude: 33.4484,
                    longitude: -112.0740,
                    addressMin: "Phoenix Public Library, Phoenix, AZ",
                    note: "Started reading 'The Catcher in the Rye'",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 37.7749,
                    longitude: -122.4194,
                    addressMin: "City Lights Bookstore, San Francisco, CA",
                    note: "Bought '1984' by George Orwell",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                ),
                .init(
                    latitude: 40.7128,
                    longitude: -74.0060,
                    addressMin: "The Strand, New York, NY",
                    note: "Finished 'To Kill a Mockingbird'",
                    recordDate: Date().add(days: -Int.random(in: 1...10))
                )
            ]

            let books: Model.TrackedEntity = .init(
                id: UUID().uuidString,
                name: "Books",
                info: "A list of books I am currently reading or have completed",
                archived: false,
                favorite: true,
                locationRelevant: false,
                category: .personal,
                sound: .cheer1,
                cascadeEvents: bookEvents
            )

            trackedEntityInsert(trackedEntity: books)
            trackedEntityInsert(trackedEntity: concerts)
            trackedEntityInsert(trackedEntity: coffee)
            trackedEntityInsert(trackedEntity: cinema)
            trackedEntityInsert(trackedEntity: chess)
            trackedEntityInsert(trackedEntity: gymnasium)
        }
    }
}
