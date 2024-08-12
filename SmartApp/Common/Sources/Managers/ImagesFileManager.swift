//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import MobileCoreServices

public extension Common {
    enum FileManager {
        public static var `default` = Foundation.FileManager.default
        public static var defaultSearchPath: Foundation.FileManager.SearchPathDirectory { .documentDirectory }

        public static var defaultFolder: String {
            let fileManager = FileManager.default
            let paths = NSSearchPathForDirectoriesInDomains(defaultSearchPath, .userDomainMask, true)
            guard let documentsDirectory = paths.first else {
                // Fallback cache directory
                return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
            }

            if !fileManager.fileExists(atPath: documentsDirectory) {
                // Fallback cache directory
                return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
            }
            return documentsDirectory
        }
    }

    enum ImagesFileManager {
        public static func allImageNames(in folderPath: String = Common.FileManager.defaultFolder) -> [String]? {
            var result: [String] = []
            do {
                let folderURL = URL(fileURLWithPath: folderPath)
                let fileURLs = try Common.FileManager.default.contentsOfDirectory(
                    at: folderURL,
                    includingPropertiesForKeys: nil
                )
                result = fileURLs.map(\.lastPathComponent)
                    .filter { $0.hasSuffix(".png") }
            } catch {
                Common_Logs.error("\(error)")
            }
            return result
        }

        public static func imageWith(name: String, completion: @escaping (_ image: UIImage?, _ urlPath: URL?) -> Void) {
            Common_Utils.executeInBackgroundTread {
                let namePNG = name.hasSuffix(".png") ? name : "\(name).png"
                let filePath = (Common.FileManager.defaultFolder as NSString).appendingPathComponent(namePNG)
                if let image = UIImage(contentsOfFile: filePath) {
                    let urlPath = URL(fileURLWithPath: filePath)
                    Common_Utils.executeInMainTread {
                        completion(image, urlPath)
                    }
                }
            }
        }

        public static func imageWith(name: String) -> (image: UIImage?, urlPath: URL?) {
            let namePNG = name.hasSuffix(".png") ? name : "\(name).png"
            let filePath = (Common.FileManager.defaultFolder as NSString).appendingPathComponent(namePNG)
            if let image = UIImage(contentsOfFile: filePath) {
                let urlPath = URL(fileURLWithPath: filePath)
                return (image, urlPath)
            }
            return (nil, nil)
        }

        @discardableResult
        public static func saveImageWith(name: String, image: UIImage) -> (success: Bool, urlPath: URL?) {
            Common_Utils.assert(!name.contains("/"), message: "Invalid image name [\(name)]")
            Common_Utils.assert(!name.contains("\\"), message: "Invalid image name [\(name)]")
            guard !name.isEmpty else {
                return (false, nil)
            }
            let namePNG = name.hasSuffix(".png") ? name : "\(name).png"
            let path = Common.FileManager.defaultFolder + "/" + namePNG
            return saveImageWith(urlPath: URL(fileURLWithPath: path), image: image)
        }

        @discardableResult
        public static func saveImageWith(urlPath: URL, image: UIImage) -> (success: Bool, urlPath: URL?) {
            var result: (success: Bool, urlPath: URL?) = (false, nil)
            if let data = image.pngData() {
                let operation: ()? = try? data.write(to: urlPath, options: [.atomic])
                if operation == nil {
                    Common_Logs.error("Fail saving \(image) using urlPath [\(urlPath)]")
                }
                result = (operation != nil, urlPath)
            }
            return result
        }

        public static func deleteAll(in folderPath: String = Common.FileManager.defaultFolder) {
            let fileManager = Common.FileManager.default
            let directory = fileManager.urls(for: Common.FileManager.defaultSearchPath, in: .userDomainMask).first!
            let urls = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            guard let urls else {
                return
            }
            for url in urls {
                let isImage = imageWith(name: url.lastPathComponent).image != nil
                if isImage {
                    try? fileManager.removeItem(at: url)
                }
            }
        }

        /// Will delete all the images on the folder `folderPath`, if any part of the name contains `namePart`
        public static func deleteAll(in folderPath: String = Common.FileManager.defaultFolder, namePart: String) {
            guard !namePart.isEmpty else {
                return
            }
            let fileManager = Common.FileManager.default
            let directory = fileManager.urls(for: Common.FileManager.defaultSearchPath, in: .userDomainMask).first!
            let urls = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            guard let urls else {
                return
            }
            for url in urls {
                if url.absoluteString.contains(namePart) {
                    let isImage = imageWith(name: url.lastPathComponent).image != nil
                    if isImage {
                        try? fileManager.removeItem(at: url)
                    }
                }
            }
        }

        public static func delete(name: String, in folderPath: String = Common.FileManager.defaultFolder) -> Bool {
            guard !name.isEmpty else { return false }
            var result = false
            let urlPath = URL(fileURLWithPath: Common.FileManager.defaultFolder).appendingPathComponent(name)
            if !Common.FileManager.default.fileExists(atPath: urlPath.path) {
                result = false
            } else {
                do {
                    try Common.FileManager.default.removeItem(at: urlPath)
                    result = true
                } catch {
                    result = false
                }
            }
            return result
        }
    }
}

public extension UIImage {
    @discardableResult
    func saveWith(urlPath: URL) -> (success: Bool, urlPath: URL?) {
        Common.ImagesFileManager.saveImageWith(urlPath: urlPath, image: self)
    }

    @discardableResult
    func saveWith(name: String) -> (success: Bool, urlPath: URL?) {
        Common.ImagesFileManager.saveImageWith(name: name, image: self)
    }
}
