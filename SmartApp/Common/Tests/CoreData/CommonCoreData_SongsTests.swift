//
//  Created by Ricardo Santos on 12/08/2024.
//

import XCTest
import Foundation
import Combine
import Nimble
@testable import Common

class CommonCoreData_SongsTests: XCTestCase {
    
    // Enable or disable tests (for debugging or conditional execution)
    func enabled() -> Bool {
        true
    }

    // Database repository instance, shared across tests
    var bd: CommonCoreData.Utils.Sample.DataBaseRepository = {
        .shared
    }()

    // Setup method called before each test
    override func setUp() {
        super.setUp()
        continueAfterFailure = false // Stops the test execution if a failure occurs
        TestsGlobal.loadedAny = nil
        TestsGlobal.cancelBag.cancel() // Clears any subscriptions in the cancel bag
    }
}

extension CommonCoreData_SongsTests {
    
    // Creates a random CDataSinger instance with an optional number of songs
    @discardableResult
    func randomCDataSinger(songs: Int = 0) -> CDataSinger {
        let singer = bd.newSingerInstance(name: "Singer \(String.random(10))")
        if songs > 0 {
            // Create an array of songs and add them to the singer
            let songs = (0...(songs-1)).map { bd.newSongInstance(title: "Song \($0)", releaseDate: Date.now) }
            songs.forEach { song in
                singer.addToSongs(song)
            }
        }
        return singer
    }
    
    // Creates and saves a random CDataSinger instance with an optional number of songs
    @discardableResult
    func saveRandomCDataSinger(songs: Int = 0) -> CDataSinger {
        let singer = randomCDataSinger(songs: songs)
        bd.save() // Save the singer and its songs to the database
        return singer
    }
}

//
// MARK: - CRUD (Create, Read, Update, Delete) Tests
//
extension CommonCoreData_SongsTests {
    
    // Test to ensure that deleting a singer also deletes the associated songs (cascade delete)
    func test_cascadeDelete() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        
        bd.deleteAllSingers() // Clear all existing singers

        saveRandomCDataSinger(songs: 1) // Save a singer with one song

        // Assert that the singer and song were saved
        XCTAssert(bd.allSingers().count == 1)
        XCTAssert(bd.allSongs().count == 1)
        
        bd.deleteAllSingers() // Delete all singers
        
        // Assert that deleting the singer also deletes the song
        XCTAssert(bd.allSongs().count == 0)
        XCTAssert(bd.allSingers().count == 0)
    }
    
    // Test to save a singer with one song and verify the correct saving
    func test_saveSingerWith1Song() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.deleteAllSingers() // Clear all existing singers
        saveRandomCDataSinger(songs: 1) // Save a singer with one song
        
        // Assert that one singer and one song exist in the database
        XCTAssert(bd.allSingers().count == 1)
        XCTAssert(bd.allSongs().count == 1)
    }
    
    // Test to verify that deleting a specific singer does not affect other singers
    func test_deleteSpecificSinger() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.deleteAllSingers() // Clear all existing singers
        let singer1 = saveRandomCDataSinger(songs: 1) // Save the first singer
        let singer2 = saveRandomCDataSinger(songs: 2) // Save the second singer
        
        // Delete the first singer
        bd.deleteSinger(singer: singer1)
        
        // Assert that the second singer and their songs still exist
        XCTAssert(bd.allSingers().count == 1)
        XCTAssert(bd.allSongs().count == 2)
        XCTAssert(bd.allSingers().first == singer2)
    }
    
    // Test to map a singer to a model and verify the integrity of related data
    func test_singerMapToModel() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.deleteAllSingers() // Clear all existing singers
        let singer: CDataSinger = saveRandomCDataSinger(songs: 1) // Save a singer with one song
        let singerModel: CommonCoreData.Utils.Sample.Singer = singer.mapToModel // Map singer to model
        
        // Assert the singer has one song and the mapping to model retains that relation
        XCTAssert(singer.songs?.count == 1)
        XCTAssert(singer.songs?.count ?? 0 == singerModel.refSongs?.count ?? 0)
        XCTAssert(bd.allSongs().count == 1) // Assert the song exists in the database
    }
    
    // Test to map a song to a model and verify the inclusion or exclusion of related singer
    func test_songMapToModel() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.deleteAllSingers() // Clear all existing singers
        let singer: CDataSinger = saveRandomCDataSinger(songs: 1) // Save a singer with one song
        let songModelWithSinger: CommonCoreData.Utils.Sample.Song? = bd.allSongs().first?.mapToModel(includeRelations: true)
        let songModelWithoutSinger: CommonCoreData.Utils.Sample.Song? = bd.allSongs().first?.mapToModel(includeRelations: false)
        
        // Assert the song is correctly mapped with or without the singer relation
        XCTAssert(singer.songs?.count == 1)
        XCTAssert(songModelWithSinger?.refSinger?.name == singer.name)
        XCTAssert(songModelWithoutSinger?.refSinger == nil)
    }
    
    // Test to save a singer with three songs and verify the correct saving
    func test_saveSingerWith3Song() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.deleteAllSingers() // Clear all existing singers
        saveRandomCDataSinger(songs: 3) // Save a singer with three songs
        
        // Assert that one singer and three songs exist in the database
        XCTAssert(bd.allSingers().count == 1)
        XCTAssert(bd.allSongs().count == 3)
    }
    
    // Test to delete all songs and verify that the singer still exists
    func test_deleteSong() {
        guard enabled() else {
            XCTAssert(true)
            return
        }
        bd.deleteAllSingers() // Clear all existing singers
        saveRandomCDataSinger(songs: 1) // Save a singer with one song
        bd.deleteAllSongs() // Delete all songs
        
        // Assert that the singer exists but the song does not
        XCTAssert(bd.allSingers().count == 1)
        XCTAssert(bd.allSongs().count == 0)
    }
    
    // Test to check performance when saving a large number of songs
     func test_performanceSaveManySongs() {
         guard enabled() else {
             XCTAssert(true)
             return
         }
         bd.deleteAllSingers() // Clear all existing singers
         
         // Time: 0.010 sec
         measure {
             saveRandomCDataSinger(songs: 1000) // Save a singer with 1000 songs
         }
         
         print(bd.allSongs().count)
         XCTAssert(bd.allSingers().count == 1 * 10)
         XCTAssert(bd.allSongs().count == 1000 * 10)
     }
}
