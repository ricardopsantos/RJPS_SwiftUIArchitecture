//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine

public class CronometerAverageMetrics: NSObject {
    override private init() {}

    private static var defaultsKey = "\(Common.AppInfo.version).\(CronometerAverageMetrics.self)"
    public static var shared: CronometerAverageMetrics = loadFromUserDefaults()

    @PWThreadSafe var measuresCount: [String: Double] = [:]
    @PWThreadSafe var measuresTime: [String: Double] = [:]

    public required init?(coder: NSCoder) {
        if let countDictionary = coder.decodeObject(forKey: "measuresCount") as? [String: Double],
           let timeDictionary = coder.decodeObject(forKey: "measuresTime") as? [String: Double] {
            self.measuresCount = countDictionary
            self.measuresTime = timeDictionary
        }
    }

    private init(measuresCount: [String: Double], measuresTime: [String: Double]) {
        self.measuresCount = measuresCount
        self.measuresTime = measuresTime
    }
}

//
// MARK: - Public
//

public extension CronometerAverageMetrics {
    func start(key: String) {
        let identifier = buildKey(with: key)
        Common.CronometerManager.startTimerWith(identifier: identifier)
    }

    @discardableResult
    func end(key: String) -> Double {
        let identifier = buildKey(with: key)
        let time = Common.CronometerManager.timeElapsed(identifier)
        updateMetrics(key: identifier, time: time)
        saveToUserDefaults()
        return time ?? 0
    }

    var reportV1: [String: Any] {
        var result: [String: Any] = [:]
        for (key, count) in measuresCount {
            let totalTime = measuresTime[key] ?? 0.0
            let averageTime = count > 0 ? totalTime / count : 0.0
            var metrics: [String: String] = [:]
            metrics["total"] = Int(count).description
            metrics["avg"] = String(format: "%.2f", averageTime)
            result[key] = metrics
        }
        return result
    }

    var reportV2: String {
        var result: String = ""
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
    func buildKey(with: String) -> String {
        with.replace("(_:)", with: "")
    }

    func updateMetrics(key: String, time: Double?) {
        guard let time else { return }
        let identifier = buildKey(with: key)
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

    func saveToUserDefaults() {
        let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        UserDefaults.standard.set(encodedData, forKey: Self.defaultsKey)
    }

    static func loadFromUserDefaults() -> CronometerAverageMetrics {
        if let encodedData = UserDefaults.standard.data(forKey: Self.defaultsKey),
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

extension CronometerAverageMetrics: NSCoding {
    public func encode(with coder: NSCoder) {
        coder.encode(measuresCount, forKey: "measuresCount")
        coder.encode(measuresTime, forKey: "measuresTime")
    }
}
