//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

// The CronometerAverageMetrics class tracks and calculates average metrics for different keys (or identifiers).
// It manages the start and end of timing operations, updates the metrics, and provides reports.
public class CronometerAverageMetrics: NSObject {
    // Shared instance of CronometerAverageMetrics using the Singleton pattern, loaded from UserDefaults.
    public static var shared: CronometerAverageMetrics = loadFromUserDefaults()

    // Private initializer to prevent direct instantiation outside the class.
    override private init() {}

    // Static variable to store the key for UserDefaults, combining the app version and the class name.
    private static var defaultsKey: String {
        "V\(Common.AppInfo.version).\(CronometerAverageMetrics.self)".replace(" ", with: "")
    }

    // Thread-safe properties to store counts and times for different keys.
    @PWThreadSafe var measuresCount: [String: Double] = [:]
    @PWThreadSafe var measuresTime: [String: Double] = [:]

    // Required initializer for decoding from NSCoder.
    public required init?(coder: NSCoder) {
        // Decode the dictionaries from the coder.
        if let countDictionary = coder.decodeObject(forKey: "measuresCount") as? [String: Double],
           let timeDictionary = coder.decodeObject(forKey: "measuresTime") as? [String: Double] {
            self.measuresCount = countDictionary
            self.measuresTime = timeDictionary
        }
    }

    // Private initializer for creating an instance with given count and time dictionaries.
    private init(measuresCount: [String: Double], measuresTime: [String: Double]) {
        self.measuresCount = measuresCount
        self.measuresTime = measuresTime
    }
}

//
// MARK: - Public
//

public extension CronometerAverageMetrics {
    func clear() {
        let keys = Common.userDefaults?.dictionaryRepresentation().keys
            .filter { $0.contains(Self.defaultsKey) }
        keys?.forEach { key in
            Common.userDefaults?.removeObject(forKey: key)
        }
        Common.userDefaults?.synchronize()
        measuresCount.removeAll()
        measuresTime.removeAll()
    }

    // Starts the timer for a given key by building an identifier and passing it to the CronometerManager.
    func start(key: String) {
        let identifier = buildKey(with: key)
        Common_CronometerManager.startTimerWith(identifier: identifier)
    }

    // Ends the timer for a given key, updates the metrics, saves to UserDefaults, and returns the elapsed time.
    @discardableResult
    func end(key: String) -> Double {
        let identifier = buildKey(with: key)
        let time = Common_CronometerManager.timeElapsed(identifier)
        updateMetrics(key: identifier, time: time)
        saveToUserDefaults()
        return time ?? 0
    }

    func averageTimeFor(key: String) -> Double {
        let identifier = buildKey(with: key)
        if let dic = reportV1[identifier] as? [String: String] {
            return dic["avg"]?.doubleValue ?? 0
        }
        return 0
    }

    // Generates a report (version 1) as a dictionary, containing total and average time for each key.
    var reportV1: [String: Any] {
        var result: [String: Any] = [:]
        for (key, count) in measuresCount {
            let totalTime = measuresTime[key] ?? 0.0
            let averageTime = count > 0 ? totalTime / count : 0.0
            var metrics: [String: String] = [:]
            metrics["total"] = Int(count).description
            metrics["avg"] = String(format: "%.6f", averageTime)
            result[key] = metrics
        }
        return result
    }

    // Generates a report (version 2) as a formatted string, containing total and average time for each key.
    var reportV2: String {
        var result: String = ""
        // Sorts the keys alphabetically in descending order before generating the report.
        for (key, count) in measuresCount
            .sorted(by: { $0.key > $1.key }) {
            let displayKey = key
            let totalTime = measuresTime[key] ?? 0.0
            let averageTime = count > 0 ? totalTime / count : 0.0
            let averageTime2 = averageTime.description.prefix(4)
            result += " • \(displayKey) - Total:\(Int(count)), Avg:\(averageTime2)(s)\n"
        }
        return result
    }
}

//
// MARK: - Private
//

private extension CronometerAverageMetrics {
    // Builds a key by removing specific characters (here, "(_:)") from the input string.
    func buildKey(with: String) -> String {
        with.replace("(_:)", with: "")
    }

    // Updates the count and time metrics for a given key, creating entries if necessary.
    func updateMetrics(key: String, time: Double?) {
        guard let time else { return }
        let identifier = buildKey(with: key)

        // Update the request count
        if var count = measuresCount[identifier] {
            count += 1
            measuresCount[identifier] = count
        } else {
            measuresCount[identifier] = 1
        }

        // Update the request time
        if var totalTime = measuresTime[identifier] {
            totalTime += time
            measuresTime[identifier] = totalTime
        } else {
            measuresTime[identifier] = time
        }
    }

    // Saves the current state of the instance to UserDefaults.
    func saveToUserDefaults() {
        let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        Common.userDefaults?.set(encodedData, forKey: Self.defaultsKey)
    }

    // Loads a saved instance from UserDefaults, or creates a new instance if none exists.
    static func loadFromUserDefaults() -> CronometerAverageMetrics {
        if let encodedData = Common.userDefaults?.data(forKey: Self.defaultsKey),
           let instance = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encodedData) as? CronometerAverageMetrics {
            return instance
        } else {
            return CronometerAverageMetrics()
        }
    }
}

//
// MARK: - NSCoding
//

// Implements the NSCoding protocol to encode the instance into NSCoder for persistence.
extension CronometerAverageMetrics: NSCoding {
    public func encode(with coder: NSCoder) {
        coder.encode(measuresCount, forKey: "measuresCount")
        coder.encode(measuresTime, forKey: "measuresTime")
    }
}
