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
     

        if trackedLogGetAll(cascade: false).count == 0 {
            let coffeeEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "Starbucks",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Tim Hortons",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Dunkin",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Costa Coffee",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "The Coffee Bean & Tea Leaf",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
            ]
            let coffee: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                    name: "Coffee",
                                                    info: "To track the amount of coffee I drink",
                                                    archived: false,
                                                    favorite: true,
                                                    autoPresentLog: true,
                                                    locationRelevant: true,
                                                    category: .cultural,
                                                    sound: .boo1,
                                                    cascadeEvents: coffeeEvents)
            
            let gymnasiumEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "Holmes Place",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Outdoor",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Holmes Place",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Outdoor",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Outdoor",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
            ]
            let gymnasium: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                    name: "Gymnasium",
                                                    info: "",
                                                    archived: false,
                                                    favorite: false,
                                                    autoPresentLog: true,
                                                    locationRelevant: true,
                                                    category: .health,
                                                    sound: .cheer1,
                                                    cascadeEvents: gymnasiumEvents)
            let cinemaEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "Avengers: Endgame",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Jurassic World",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "The Dark Knight",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Avatar",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Inception",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Black Panther",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Star Wars: The Force Awakens",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
            ]

                
            let cinema: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                    name: "Cinema",
                                                    info: "",
                                                    archived: false,
                                                    favorite: false,
                                                    autoPresentLog: true,
                                                    locationRelevant: true,
                                                    category: .cultural,
                                                    sound: .cheer1,
                                                    cascadeEvents: cinemaEvents)
            let chessEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "Tata Steel Chess Tournament",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Candidates Tournamen",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Sinquefield Cup",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
                ]
                
            let chess: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                    name: "Chess Tournaments",
                                                    info: "",
                                                    archived: false,
                                                    favorite: false,
                                                    autoPresentLog: true,
                                                    locationRelevant: true,
                                                    category: .personal,
                                                    sound: .cheer1,
                                                    cascadeEvents: chessEvents)
            
            let concertEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "Coldplay Live",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Beyoncé Concert",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Ed Sheeran Tour",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Taylor Swift Concert",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "The Weeknd Live",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
            ]

            let concerts: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                      name: "Concerts",
                                                      info: "",
                                                      archived: false,
                                                      favorite: true,
                                                      autoPresentLog: true,
                                                      locationRelevant: true,
                                                      category: .cultural,
                                                      sound: .cheer1,
                                                      cascadeEvents: concertEvents)

            let bookEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "To Kill a Mockingbird",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "1984 by George Orwell",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "The Great Gatsby",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Pride and Prejudice",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "The Catcher in the Rye",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
            ]

            let books: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                   name: "Books Read",
                                                   info: "Track your reading list",
                                                   archived: false,
                                                   favorite: false,
                                                   autoPresentLog: true,
                                                   locationRelevant: false,
                                                   category: .personal,
                                                   sound: .boo1,
                                                   cascadeEvents: bookEvents)
            let restaurantEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "Joe's Diner",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Olive Garden",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "The Cheesecake Factory",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Ruth's Chris Steak House",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Chipotle Mexican Grill",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
            ]

            let restaurants: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                         name: "Restaurants",
                                                         info: "Track the places you eat",
                                                         archived: false,
                                                         favorite: false,
                                                         autoPresentLog: true,
                                                         locationRelevant: true,
                                                         category: .cultural,
                                                         sound: .cheer1,
                                                         cascadeEvents: restaurantEvents)
            let hikeEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "Mountain Trail",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Forest Walk",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Lake Loop",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "River Trail",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Desert Path",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
            ]

            let hikes: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                   name: "Hikes",
                                                   info: "Track your hiking adventures",
                                                   archived: false,
                                                   favorite: true,
                                                   autoPresentLog: true,
                                                   locationRelevant: true,
                                                   category: .health,
                                                   sound: .cheer1,
                                                   cascadeEvents: hikeEvents)
            let recipeEvents: [Model.TrackedLog] = [
                .init(latitude: 0,
                      longitude: 0,
                      note: "Spaghetti Carbonara",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Chicken Tikka Masala",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Beef Stroganoff",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Vegetarian Lasagna",
                      recordDate: Date().add(days: -Int.random(in: 1...10))),
                .init(latitude: 0,
                      longitude: 0,
                      note: "Chocolate Cake",
                      recordDate: Date().add(days: -Int.random(in: 1...10)))
            ]

            let recipes: Model.TrackedEntity = .init(id: UUID().uuidString,
                                                     name: "Cooking Recipes",
                                                     info: "Track the recipes you cook",
                                                     archived: false,
                                                     favorite: false,
                                                     autoPresentLog: true,
                                                     locationRelevant: false,
                                                     category: .personal,
                                                     sound: .boo1,
                                                     cascadeEvents: recipeEvents)

            trackedEntityInsert(trackedEntity: recipes)
            trackedEntityInsert(trackedEntity: hikes)
            trackedEntityInsert(trackedEntity: restaurants)
            trackedEntityInsert(trackedEntity: books)
            trackedEntityInsert(trackedEntity: concerts)
            trackedEntityInsert(trackedEntity: coffee)
            trackedEntityInsert(trackedEntity: cinema)
            trackedEntityInsert(trackedEntity: chess)
            trackedEntityInsert(trackedEntity: gymnasium)
        }
    }
    
}

