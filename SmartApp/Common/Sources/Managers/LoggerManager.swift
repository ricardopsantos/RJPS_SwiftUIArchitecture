//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable logs_rule_1

// MARK: - Logger (Public)

public extension Common {
    struct LogsManager {
        private init() {}

        public static var maxLogSize = 2_000
        @PWThreadSafe private static var debugCounter: Int = 0
        public static func cleanStoredLogs() {
            StorageUtils.deleteAllLogs()
        }

        public static func debug(
            _ message: Any?,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) {
            guard message != nil else {
                return
            }
            let prefix = "🟢 "
            private_print("\(prefix)\(message!)", function: function, file: file, line: line)
        }

        public static func warning(
            _ message: Any?,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) {
            guard message != nil else {
                return
            }
            let prefix = "🟡 "
            private_print("\(prefix)\(message!)", function: function, file: file, line: line)
        }

        public static func error(
            _ message: Any?,
            shouldCrash: Bool = false,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) {
            guard message != nil else {
                return
            }
            let prefix = "🔴 "
            private_print("\(prefix)\(message!)", function: function, file: file, line: line)
        }

        //
        // Log to console/terminal
        //

        public static func prettyPrinted(
            _ message: @autoclosure () -> String,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) -> String {
            debugCounter += 1
            let senderCodeId = Common_Utils.senderCodeId(function, file: file, line: line)
            let date = Date.utcNow
            let logMessage = """
            ⚙️ \(Common.self).Log_\(debugCounter) @ (\(date)) \(senderCodeId)
            ⚙️ \(message())
            """
            return logMessage
        }

        private static func private_print(
            _ message: @autoclosure () -> String,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) {
            // When performed on physical device, NSLog statements appear in the device's console whereas
            // print only appears in the debugger console.
            #if DEBUG
            let logMessage = prettyPrinted(message(), function: function, file: file, line: line).replace(" +0000", with: "")
            if Common_Utils.onSimulator {
                print(logMessage + "\n")
            } else {
                print(logMessage.prefix(maxLogSize) + "\n")
            }
            if false {
                StorageUtils.appendToFileEnd(String(logMessage.prefix(maxLogSize)))
            }
            #endif
        }
    }
}

// MARK: - Logger (Private)

public extension Common.LogsManager {
    enum StorageUtils {
        /**
         In Swift, it's generally not recommended to perform file I/O operations on the main thread, especially if those operations are time-consuming
         or can potentially block the UI. File I/O can be slow, and performing it on the main thread can result in a poor user experience, including unresponsive user interfaces.
         */
        @PWThreadSafe fileprivate static var dispatchQueue = DispatchQueue(label: "\(logFilePrefix)", qos: .background)
        @PWThreadSafe fileprivate static var fileManager: FileManager = Common.FileManager.default
        @PWThreadSafe fileprivate static var _logFile: URL?
        fileprivate static var logFilePrefix = "\(Common.self).\(Common.LogsManager.self)"
        fileprivate static var logsFolder: URL? = fileManager.urls(
            for: Common.FileManager.defaultSearchPath,
            in: .userDomainMask
        ).first

        fileprivate static var logFile: URL? {
            if let _logFile {
                return _logFile
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let fileDynamicSuffic = dateFormatter.string(from: Date.utcNow)
            let dynamicFileName = "\(logFilePrefix)@\(fileDynamicSuffic).log"
            let fileName = dynamicFileName
            guard let logsFolder else {
                return nil
            }
            _logFile = logsFolder.appendingPathComponent(fileName)
            return _logFile
        }

        public static func deleteLastLog() {
            Self.dispatchQueue.async {
                deleteAllLogs()
            }
        }

        public static func deleteAllLogs() {
            Self.dispatchQueue.async {
                guard let logsFolder else {
                    return
                }
                if let contents = try? fileManager.contentsOfDirectory(
                    at: logsFolder,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                ) {
                    for file in contents {
                        if "\(file)".contains(logFilePrefix), fileManager.isDeletableFile(atPath: file.path) {
                            try? fileManager.removeItem(atPath: file.path)
                        }
                    }
                }
            }
        }

        public static var allLogs: [(logId: String, logContent: String)] {
            guard let logsFolder else {
                return []
            }
            var acc: [(logId: String, logContent: String)] = []
            if let contents = try? fileManager.contentsOfDirectory(
                at: logsFolder,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) {
                for file in contents {
                    if "\(file)".contains(logFilePrefix), fileManager.isDeletableFile(atPath: file.path) {
                        if let content = try? String(contentsOf: file, encoding: String.Encoding.utf8) {
                            if var id = "\(file.path)".split(by: "/").last {
                                id = id.replace(".log", with: "").replace("@", with: "").replace("_", with: " ")
                                id = id.replace(logFilePrefix, with: "")
                                acc.append((logId: id, logContent: content))
                            }
                        }
                    }
                }
            }
            return acc
        }

        public static var lastLog: String? {
            guard let logFile else {
                return nil
            }
            return try? String(contentsOf: logFile, encoding: String.Encoding.utf8)
        }

        public static func appendToFileStart(_ log: String) {
            Self.dispatchQueue.async {
                guard let logFile else {
                    return
                }
                let currentFile = lastLog ?? ""
                guard let data = "\(log)\n\(currentFile)".data(using: String.Encoding.utf8) else {
                    return
                }
                if fileManager.fileExists(atPath: logFile.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                        defer {
                            fileHandle.closeFile()
                        }
                        fileHandle.write(data)
                    }
                } else {
                    try? data.write(to: logFile, options: .atomicWrite)
                }
            }
        }

        public static func appendToFileEnd(_ log: String) {
            Self.dispatchQueue.async {
                guard let logFile else {
                    return
                }
                guard let data = "\(log)\n".data(using: String.Encoding.utf8) else {
                    return
                }
                if fileManager.fileExists(atPath: logFile.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                        defer {
                            fileHandle.closeFile()
                        }
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                    }
                } else {
                    try? data.write(to: logFile, options: .atomicWrite)
                }
            }
        }
    }
}

// swiftlint:enable logs_rule_1
