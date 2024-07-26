//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

// MARK: - Cache

public final class CacheManager<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()

    public init(
        dateProvider: @escaping () -> Date = Date.init,
        entryLifetime: TimeInterval = 12 * 60 * 60,
        maximumEntryCount: Int = 50
    ) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }

    public func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }

    public func update(_ value: Value, forKey key: Key) {
        if self.value(forKey: key) != nil {
            removeValue(forKey: key)
        }
        insert(value, forKey: key)
    }

    public func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

// MARK: - Cache Subscript

public extension CacheManager {
    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

// MARK: Cache.WrappedKey

private extension CacheManager {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

// MARK: Cache.Entry

private extension CacheManager {
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date

        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

// MARK: Cache.KeyTracker

private extension CacheManager {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()

        func cache(
            _: NSCache<AnyObject, AnyObject>,
            willEvictObject obj: Any
        ) {
            guard let entry = obj as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }
}

// MARK: - Cache.Entry + Codable

extension CacheManager.Entry: Codable where Key: Codable, Value: Codable {}

private extension CacheManager {
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard Date() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

// MARK: - Cache + Codable

extension CacheManager: Codable where Key: Codable, Value: Codable {
    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
}

// MARK: - Cache Save To Disk

extension CacheManager where Key: Codable, Value: Codable {
    func saveToDisk(
        with name: String,
        using fileManager: FileManager = .default
    ) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
}

extension CacheManager {
    static func sampleUsage() {
        // Create a cache instance
        let cache = CacheManager<String, Int>()

        // Insert a value for a key
        cache.insert(42, forKey: "answer")

        // Retrieve a value for a key
        if let answer = cache.value(forKey: "answer") {
            Common.LogsManager.debug("The answer is \(answer)")
        }

        // Update a value for a key
        cache.update(43, forKey: "answer")

        // Use the subscript to insert a value
        cache["newKey"] = 123

        // Use the subscript to retrieve a value
        if let value = cache["newKey"] {
            Common.LogsManager.debug("The value for newKey is \(value)")
        }

        // Use the subscript to remove a value
        cache["newKey"] = nil

        // Save a cache to disk
        do {
            try cache.saveToDisk(with: "myCache")
        } catch {
            Common.LogsManager.debug("Error saving cache to disk: \(error)")
        }

        // Load a cache from disk
        do {
            let fileManager = FileManager.default
            let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            let fileURL = folderURLs[0].appendingPathComponent("myCache.cache")
            let data = try Data(contentsOf: fileURL)
            let decodedCache = try JSONDecoder().decodeFriendly(CacheManager<String, Int>.self, from: data)
            Common.LogsManager.debug("Loaded cache from disk: \(decodedCache)")
        } catch {
            Common.LogsManager.debug("Error loading cache from disk: \(error)")
        }
    }
}
