//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

// https://medium.com/@zippicoder/downsampling-images-for-better-memory-consumption-and-uicollectionview-performance-35e0b4526425
// https://swiftsenpai.com/development/reduce-uiimage-memory-footprint/
// https://medium.com/swift2go/reducing-memory-footprint-when-using-uiimage-ef0b1742cc23

public extension UIImage {
    enum ContentMode {
        case contentFill
        case contentAspectFill
        case contentAspectFit

        public static var `default`: Self {
            .contentAspectFit
        }
    }
}

public extension UIImage {
    // imageURL : The image URL. It can be a web URL or a local image path
    // pointSize: The desired size of the downsampled image. Usually, this will be the UIImageView's frame size.
    // scale    : The downsampling scale factor. Usually, this will be the scale factor associated with the screen
    static func downsample(
        imageAt imageURL: URL,
        size: CGSize,
        scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            Common_Logs.error("Failed on CGImageSourceCreateWithURL")
            return nil
        }
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
        }
        return downsample(image: UIImage(cgImage: cgImage), size: size, scale: scale)
    }

    static func downsample(
        image: UIImage,
        size: CGSize,
        scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        // Create an CGImageSource that represent an image
        guard let data = image.pngData(),
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        // Calculate the desired dimension
        let maxDimensionInPixels = max(size.width, size.height) * scale

        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as [CFString: Any] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        // Return the downsampled image as UIImage
        return UIImage(cgImage: downsampledImage)
    }
}

public extension UIImage {
    /// Main resize function. All the other functions use this one
    func resize(
        size targetSize: CGSize,
        contentMode: ContentMode = .default
    ) -> UIImage {
        guard size != targetSize else { return self }
        let aspectWidth = targetSize.width / size.width
        let aspectHeight = targetSize.height / size.height

        func resizeOperation(with size: CGSize) -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            draw(in: CGRect(origin: .zero, size: size))
            return UIGraphicsGetImageFromCurrentImageContext()
        }

        switch contentMode {
        case .contentFill:
            return resizeOperation(with: size) ?? self
        case .contentAspectFit:
            let aspectRatio = min(aspectWidth, aspectHeight)
            return resizeOperation(with: CGSize(width: size.width * aspectRatio, height: size.height * aspectRatio)) ?? self
        case .contentAspectFill:
            let aspectRatio = max(aspectWidth, aspectHeight)
            return resizeOperation(with: CGSize(width: size.width * aspectRatio, height: size.height * aspectRatio)) ?? self
        }
    }

    func resize(
        percentage: CGFloat, // [0, 1]
        contentMode: ContentMode = .default
    ) -> UIImage? {
        var value = percentage > 1 ? 1 : percentage
        value = value < 0 ? 0 : value
        return resize(
            size: .init(
                width: size.width * value,
                height: size.height * value
            ),
            contentMode: contentMode
        )
    }

    func resizeToFitMaxSize(
        maxWidth: Double? = nil,
        maxHeight: Double? = nil,
        maxSizeMB: Double? = 10,
        pngData: Bool = false,
        jpgData: Bool = true
    ) -> UIImage? {
        guard pngData || jpgData else {
            fatalError("Pick one")
        }

        // Resize image by width and height, if needed
        let maxWidth = maxWidth ?? size.width
        let maxHeight = maxHeight ?? size.height
        var resizedImage = resize(size: .init(width: maxWidth, height: maxHeight), contentMode: .contentAspectFit)

        if Int(resizedImage.size.width) > Int(maxWidth + 1) {
            fatalError("size fail width")
        }
        if Int(resizedImage.size.height) > Int(maxHeight + 1) {
            fatalError("size fail height")
        }
        // Resize image by size (Mega Bytes), if needed
        if let maxSizeMB {
            resizedImage = resizedImage.resize(maxSizeMB: maxSizeMB, pngData: pngData, jpgData: jpgData)
        }

        return resizedImage
    }

    func resize(maxSizeMB: Double, pngData: Bool, jpgData: Bool) -> UIImage {
        guard maxSizeMB > 0 else {
            return self
        }
        guard pngData || jpgData else {
            fatalError("Pick one")
        }
        if pngData, sizeInMB_PNG < maxSizeMB {
            // Nothing to do
            return self
        }
        if jpgData, sizeInMB_JPEG < maxSizeMB {
            // Nothing to do
            return self
        }

        var result: UIImage = self
        var ready: Bool = false
        let decreaseK: CGFloat = 0.95
        while !ready {
            if ready {
                break
            }
            let newSize: CGSize = .init(width: result.size.width * decreaseK, height: result.size.height * decreaseK)
            if pngData {
                if result.sizeInMB_PNG < maxSizeMB {
                    ready = true
                } else {
                    result = result.resize(size: newSize, contentMode: .contentAspectFit)
                }
            } else if jpgData {
                if result.sizeInMB_JPEG < maxSizeMB {
                    ready = true
                } else {
                    result = result.resize(size: newSize, contentMode: .contentAspectFit)
                }
            }
        }
        return result
    }
}

public extension UIImage {
    static func resizeFunctionsSampleUsage() {
        guard let original = UIImage.randomImageWith(size: .init(width: 5000, height: 5000)) else { return }
        func printReport(image: UIImage?, name: String) {
            guard let image else { return }
            // swiftlint:disable logs_rule_1
            print("# ", name + ",", "dim: \(Int(image.size.width))x\(Int(image.size.height)),", "size: \(image.pngData()!.count)")
            // swiftlint:enable logs_rule_1
        }
        let originalImageHalfSize: CGSize = .init(width: original.size.width / 2, height: original.size.height / 2)

        printReport(image: original, name: "original")

        let method1Id = "50%"
        Common_CronometerManager.startTimerWith(identifier: method1Id)
        printReport(image: original.resize(percentage: 0.5), name: method1Id)
        Common_CronometerManager.timeElapsed(method1Id, print: true)

        let method2Id = "originalImageHalfSize"
        Common_CronometerManager.startTimerWith(identifier: method2Id)
        printReport(image: original.resize(size: originalImageHalfSize), name: method2Id)
        Common_CronometerManager.timeElapsed(method2Id, print: true)

        let method3Id = "resizeToFitMaxSize"
        Common_CronometerManager.startTimerWith(identifier: method3Id)
        printReport(image: original.resizeToFitMaxSize(
            maxWidth: originalImageHalfSize.width,
            maxHeight: originalImageHalfSize.height
        ), name: method3Id)
        Common_CronometerManager.timeElapsed(method3Id, print: true)

        let method4Id = "downsample"
        Common_CronometerManager.startTimerWith(identifier: method4Id)
        printReport(image: UIImage.downsample(image: original, size: originalImageHalfSize), name: method4Id)
        Common_CronometerManager.timeElapsed(method4Id, print: true)

        /**
          original, dim: 5000x5000, size: 82124962

          50%, dim: 2500x2500, size: 21315683
          ⏰ time : 0.6338319778442383

          originalImageHalfSize, dim: 2500x2500, size: 21315683
          ⏰ time : 0.6212139129638672

          resizeToFitMaxSize, dim: 972x972, size: 3129705
          ⏰ time :0.7007440328598022

          downsample, dim: 5000x5000, size: 82124974
          ⏰ time : 4.046491980552673
         */
    }
}
