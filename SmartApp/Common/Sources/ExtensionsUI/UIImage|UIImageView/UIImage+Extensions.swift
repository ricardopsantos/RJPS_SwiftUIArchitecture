//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

//
// MARK: - Convenience init
//

public extension UIImage {
    static func randomImageWith(size: CGSize) -> UIImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        let bitsPerComponent = 8
        let bytesPerPixel = 4 // RGBA

        // Calculate the image data size and allocate a buffer
        let dataSize = width * height * bytesPerPixel
        var imageData = [UInt8](repeating: 0, count: dataSize)

        for i in 0..<width * height {
            let baseIndex = i * bytesPerPixel

            // Generate random color components
            let red = UInt8.random(in: 0...255)
            let green = UInt8.random(in: 0...255)
            let blue = UInt8.random(in: 0...255)
            let alpha = UInt8.random(in: 0...255)

            // Set the pixel values in the buffer
            imageData[baseIndex] = red
            imageData[baseIndex + 1] = green
            imageData[baseIndex + 2] = blue
            imageData[baseIndex + 3] = alpha
        }

        // Create a data provider from the buffer
        let dataProvider = CGDataProvider(data: NSData(bytes: imageData, length: dataSize))

        // Create a CGImage from the data provider
        if let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bytesPerPixel * 8,
            bytesPerRow: bytesPerPixel * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: dataProvider!,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) {
            // Create a UIImage from the CGImage
            return UIImage(cgImage: cgImage)
        }

        return nil
    }

    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }

    convenience init?(
        text: String,
        textColor: UIColor = .white,
        backgroundColor: UIColor = .black,
        size: CGSize
    ) {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let rect = CGRect(origin: CGPoint.zero, size: size)

        // Fill the background color
        context.setFillColor(backgroundColor.cgColor)
        context.fill(rect)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: textColor
        ]

        // Draw the text
        let textRect = CGRect(x: 0, y: size.height / 2 - 12, width: size.width, height: 24)
        text.draw(in: textRect, withAttributes: attributes)

        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }

        self.init(cgImage: image)
        UIGraphicsEndImageContext()
    }
}

//
// MARK: - Geometry
//

public extension UIImage {
    func rotate(degrees: Float, clockwise: Bool = true) -> UIImage? {
        guard let cgImage else {
            return nil
        }
        // let radians = clockwise ? -CGFloat.pi / 2 : CGFloat.pi / 2
        let radians = clockwise ? -degrees.degreesToRadians : degrees.degreesToRadians
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let rotatedSize = CGSize(width: imageSize.height, height: imageSize.width)
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: CGFloat(radians))
        context.draw(cgImage, in: CGRect(origin: CGPoint(x: -imageSize.width / 2, y: -imageSize.height / 2), size: imageSize))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }

    func horizontalMirror() -> UIImage? {
        guard let cgImage else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.translateBy(x: size.width, y: size.height)
        context.scaleBy(x: -1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        let mirroredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return mirroredImage
    }

    func verticalMirror() -> UIImage? {
        guard let cgImage else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4 // 4 bytes per pixel (RGBA)
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let mirroredCGImage = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: mirroredCGImage)
    }
}

//
// MARK: - Misc
//

public extension UIImage {
    var sizeInMB_PNG: Double {
        guard let data = pngData() else { return 0 }
        let sizeInBytes = Double(data.count)
        let sizeInMB = sizeInBytes / (1024 * 1024)
        return sizeInMB
    }

    var sizeInMB_JPEG: Double {
        guard let data = jpegData(compressionQuality: 1.0) else { return 0 }
        let sizeInBytes = Double(data.count)
        let sizeInMB = sizeInBytes / (1024 * 1024)
        return sizeInMB
    }

    func pixelColor(at pos: CGPoint = CGPoint.zero) -> UIColor {
        guard let pixelData = cgImage?.dataProvider?.data else {
            return .black
        }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(size.width) * Int(pos.y)) + Int(pos.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
