//
//  Created by Ricardo Santos on 13/08/2024.
//

import Foundation
import CoreData

/**
 
 6 Performance Improvements for Core Data in iOS Apps
 
 https://stevenpcurtis.medium.com/5-performance-improvements-for-core-data-in-ios-apps-2dbd1ab5d601
 
 * Avoid using the viewContext for writes and only use it for reads on the main thread.
 * Only save your managed object context if it has changes to prevent unnecessary work.
 * Use NSInMemoryStoreType to test your Core Data implementation without hitting the disk.
 * Consider using multiple managed object contexts to better manage changes and save off the main thread.
 * Use fetch requests to only access the data you need and be mindful of predicates to avoid over-fetching.
 * Use batch processing with NSBatchUpdateRequest and NSBatchDeleteRequest to save time and resources when working with large amounts of data.
 */

//
// MARK: - Async Methods
//
extension CommonCoreData.Utils.Sample.DataBaseRepository {
    
    //
    // MARK: - Singer
    //
    
    func newSingerInstance(name: String) -> CDataSinger {
        typealias DBEntity = CDataSinger
        let context = viewContext
        let newInstance: DBEntity = DBEntity(context: context)
        newInstance.name = name
        return newInstance
    }
    
    func allSingers() -> [CDataSinger] {
        typealias DBEntity = CDataSinger
        let context = viewContext
        do {
            return try context.fetch(DBEntity.fetchRequest())
        } catch {
            return []
        }
    }
    
    func deleteSinger(singer: CDataSinger) {
        let context = viewContext
        context.delete(singer)
        if Common_Utils.true {
            CommonCoreData.Utils.save(viewContext: context)
        } else {
            if context.hasChanges {
                try? context.save()
            }
        }
    }
    
    func deleteAllSingers() {
        allSingers().forEach { singer in
            deleteSinger(singer: singer)
        }
    }
    
    //
    // MARK: - Song
    //
    
    func newSongInstance(title: String, releaseDate: Date) -> CDataSong {
        typealias DBEntity = CDataSong
        let context = viewContext
        let newInstance: DBEntity = DBEntity(context: context)
        newInstance.title = title
        newInstance.releaseDate = releaseDate
        return newInstance
    }
    
    func newSongInstance(title: String, releaseDate: Date, singer: CDataSinger) -> CDataSong {
        let newInstance = newSongInstance(title: title, releaseDate: releaseDate)
        singer.addToSongs(newInstance)
        return newInstance
    }
    
    func allSongs() -> [CDataSong] {
        typealias DBEntity = CDataSong
        let context = viewContext
        do {
            return try context.fetch(DBEntity.fetchRequest())
        } catch {
            return []
        }
    }
    
    func deleteAllSongs() {
        allSongs().forEach { song in
            deleteSong(song: song)
        }
    }
    
    func songs(singer: CDataSinger) -> [CDataSong] {
        typealias DBEntity = CDataSong
        let context = viewContext
        do {
            return try context.fetch(DBEntity.fetchBy(singer: singer))
        } catch {
            return []
        }
    }
    
    func deleteSong(song: CDataSong) {
        let context = viewContext
        context.delete(song)
        if Common_Utils.true {
            CommonCoreData.Utils.save(viewContext: context)
        } else {
            if context.hasChanges {
                try? context.save()
            }
        }
    }
    

}
