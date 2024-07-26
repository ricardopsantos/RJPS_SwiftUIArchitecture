//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    /// Uses the "CIPhotoEffectMono" filter to directly apply a monochrome (black and white) effect to the image.
    /// Relies on a single filter to achieve the grayscale effect.
    var grayScaleV2: UIImage? {
        let filter = CIFilter(name: "CIPhotoEffectMono")
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        if let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    /// Uses a combination of "CIColorControls" and "CIExposureAdjust" filters to adjust the brightness, contrast,
    ///  and exposure of the image to create a grayscale effect.
    /// Provides more control over the final appearance of the grayscale image through adjustments to brightness, contrast, and exposure.
    var grayScaleV1: UIImage? {
        guard let ciImage: CIImage = CIImage(image: self),
              let colorFilter: CIFilter = CIFilter(name: "CIColorControls") else {
            return nil
        }
        colorFilter.setValue(ciImage, forKey: kCIInputImageKey)
        colorFilter.setValue(0.0, forKey: kCIInputBrightnessKey)
        colorFilter.setValue(0.0, forKey: kCIInputSaturationKey)
        colorFilter.setValue(1.1, forKey: kCIInputContrastKey)
        guard let intermediateImage: CIImage = colorFilter.outputImage,
              let exposureFilter: CIFilter = CIFilter(name: "CIExposureAdjust") else {
            return nil
        }
        exposureFilter.setValue(intermediateImage, forKey: kCIInputImageKey)
        exposureFilter.setValue(0.7, forKey: kCIInputEVKey)
        guard let output = exposureFilter.outputImage else {
            return nil
        }
        let context: CIContext = CIContext(options: nil)
        guard let cgImage: CGImage = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }

    /// Paint image
    func withColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let drawRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// Sum 2 images
    static func compositeTwoImages(top: UIImage, bottom: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        // Ensure that the context was successfully created
        guard UIGraphicsGetCurrentContext() != nil else {
            return nil
        }
        bottom.draw(in: CGRect(origin: .zero, size: newSize))
        top.draw(in: CGRect(origin: .zero, size: newSize))
        // Get the composite image from the context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        ctx.restoreGState()
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

public extension UIImage {
    func cropImage(
        topRow: CGFloat,
        leftCol: CGFloat,
        bottomRow: CGFloat,
        rightCol: CGFloat
    ) -> UIImage? {
        let imageSize = size
        let topRow = topRow * imageSize.height
        let leftCol = leftCol * imageSize.width
        let bottomRow = bottomRow * imageSize.height
        let rightCol = rightCol * imageSize.width
        let cropRect = CGRect(
            x: leftCol,
            y: topRow,
            width: rightCol - leftCol,
            height: bottomRow - topRow
        )
        if let cgImage,
           let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }

    func drawBoundingBoxWithCaption(
        topRow: CGFloat,
        leftCol: CGFloat,
        bottomRow: CGFloat,
        rightCol: CGFloat,
        lineWidth: CGFloat = 8,
        caption: String = "",
        color: UIColor = .yellow,
        captionFontSize: CGFloat
    ) -> UIImage {
        let imageSize = size
        let rect = convertBoundingBoxToCGRect(
            topRow: topRow,
            leftCol: leftCol,
            bottomRow: bottomRow,
            rightCol: rightCol,
            imageSize: imageSize
        )

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        draw(at: CGPoint.zero)

        let context = UIGraphicsGetCurrentContext()

        // Draw bounding box
        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(lineWidth)
        context?.addRect(rect)
        context?.strokePath()

        if !caption.isEmpty {
            let captionRect = CGRect(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height + 5.0,
                width: rect.size.width,
                height: captionFontSize * 3
            )
            let captionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: captionFontSize),
                .foregroundColor: color
            ]
            let caption = NSAttributedString(string: caption, attributes: captionAttributes)
            caption.draw(in: captionRect)
        }

        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            return newImage
        } else {
            return self
        }
    }

    private func convertBoundingBoxToCGRect(
        topRow: CGFloat,
        leftCol: CGFloat,
        bottomRow: CGFloat,
        rightCol: CGFloat,
        imageSize: CGSize
    ) -> CGRect {
        let rect = CGRect(
            x: leftCol * imageSize.width,
            y: topRow * imageSize.height,
            width: (rightCol - leftCol) * imageSize.width,
            height: (bottomRow - topRow) * imageSize.height
        )
        return rect
    }
}
