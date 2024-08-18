//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

//
// ImageUtils
//

public extension CommonNetworking {
    enum ImageUtils {
        @PWThreadSafe static var _imagesCache = NSCache<NSString, UIImage>()
        public static var cachedImagesPrefix: String { "cached_image" }

        public enum StoragePolicy: Int {
            case none // Don't use storage
            case cold // Use cache, stored and persistent after app is closed (slow access)
            case hot // Use cache, persistent only while app is open (fast access)
            case hotElseCold // Use cache, hot first if available, else cold cache
        }

        public static func cleanCache() {
            Common.ImagesFileManager.deleteAll(namePart: Self.cachedImagesPrefix)
        }

        public static func imageFrom(
            urlString: String,
            caching: StoragePolicy,
            downsample: CGSize?
        ) async throws -> UIImage? {
            let result: UIImage? = try await withCheckedThrowingContinuation { continuation in
                imageFrom(urlString: urlString, caching: caching, downsample: downsample) { image in
                    continuation.resume(with: .success(image))
                }
            }
            return result
        }

        public static func imageFrom(
            urlString: String,
            caching: StoragePolicy,
            downsample: CGSize?,
            completion: @escaping ((UIImage?) -> Void)
        ) {
            guard let url = URL(string: urlString) else {
                DispatchQueue.executeInMainTread { completion(nil) }
                return
            }
            imageFrom(url: url, caching: caching, downsample: downsample) { some in
                completion(some)
            }
        }

        public static func imageFrom(
            urlString: String?,
            downsample: CGSize?,
            caching: StoragePolicy
        ) async throws -> UIImage? {
            guard let urlString else {
                return nil
            }
            let result: UIImage? = try await withCheckedThrowingContinuation { continuation in
                imageFrom(urlString: urlString, caching: caching, downsample: downsample) { locationForAddress in
                    continuation.resume(with: .success(locationForAddress))
                }
            }
            return result
        }

        public static func imageFrom(
            url: URL,
            caching: StoragePolicy,
            downsample: CGSize?,
            completion: @escaping ((UIImage?) -> Void)
        ) {
            let lockEnabled = false
            let cachedImageName = "\(Self.cachedImagesPrefix)" + "_" + url.absoluteString.sha1 + ".png"
            func returnImage(_ image: UIImage?) {
                autoreleasepool {
                    if let downsample,
                       let image,
                       let imageDownSample = image.resizeToFitMaxSize(maxWidth: downsample.width, maxHeight: downsample.height) {
                        DispatchQueue.executeInMainTread { completion(imageDownSample) }
                    } else {
                        DispatchQueue.executeInMainTread { completion(image) }
                    }
                    if lockEnabled {
                        Common.LockManagerV1.shared.unlock(key: cachedImageName)
                    }
                }
            }

            Common_Utils.executeInBackgroundTread {
                autoreleasepool {
                    if lockEnabled {
                        Common.LockManagerV1.shared.lock(key: cachedImageName)
                    }
                    if caching == .hot || caching == .hotElseCold,
                       let cachedImage = _imagesCache.object(forKey: cachedImageName as NSString) {
                        // Try hot cache first, is faster
                        returnImage(cachedImage)
                        return
                    } else if caching == .cold || caching == .hotElseCold,
                              let cachedImage = Common.ImagesFileManager.imageWith(name: cachedImageName).image {
                        returnImage(cachedImage)
                        return
                    } else if Common_Utils.existsInternetConnection(), let data = try? Data(contentsOf: url) {
                        var image = UIImage(data: data)
                        if image == nil {
                            // Failed? Maybe there is some encoding at start...
                            if let dataAsText = String(data: data, encoding: .utf8)?
                                .dropFirstIf("data:image/webp;base64,")
                                .dropFirstIf("data:image/jpg;base64,"),
                                let newData = Data(base64Encoded: dataAsText), let newImage = UIImage(data: newData) {
                                // Recovered!
                                image = newImage
                            }
                        }
                        returnImage(image)
                        if let image, caching == .cold || caching == .hotElseCold {
                            _ = Common.ImagesFileManager.saveImageWith(name: cachedImageName, image: image)
                        }
                        if let image, caching == .hot || caching == .hotElseCold {
                            _imagesCache.setObject(image, forKey: cachedImageName as NSString)
                        }
                    } else {
                        returnImage(nil)
                    }
                }
            }
        }
    }
}
