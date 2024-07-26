//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

//
// MARK: - Vars
//

public extension UIColor {
    var extractOpaqueColor: UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: r, green: g, blue: b, alpha: 1)
        }
        return self
    }

    var extractAlpha: CGFloat {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return a
        }
        return 1
    }

    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1
        if cgColor.components!.count == 2 {
            r = cgColor.components![0] * 255
            g = cgColor.components![0] * 255
            b = cgColor.components![0] * 255
            a = cgColor.components![1]
        } else if cgColor.components!.count >= 3 {
            r = cgColor.components![0] * 255
            g = cgColor.components![1] * 255
            b = cgColor.components![2] * 255
            if cgColor.components?.count == 4 {
                a = cgColor.components![3]
            }
        }
        let hexString = String(
            format: "#%02lX%02lX%02lX%02lX",
            lroundf(Float(r)),
            lroundf(Float(g)),
            lroundf(Float(b)),
            lroundf(Float(a))
        )
        return hexString
    }

    var rgbString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1
        if cgColor.components!.count == 2 {
            r = cgColor.components![0] * 255
            g = cgColor.components![0] * 255
            b = cgColor.components![0] * 255
            a = cgColor.components![1]
        } else if cgColor.components!.count >= 3 {
            r = cgColor.components![0] * 255
            g = cgColor.components![1] * 255
            b = cgColor.components![2] * 255
            if cgColor.components?.count == 4 {
                a = cgColor.components![3]
            }
        }
        if a == 1 {
            return "\(Int(r)),\(Int(g)),\(Int(b))"
        } else {
            return "\(Int(r)),\(Int(g)),\(Int(b)),\(a)"
        }
    }

    // https://stackoverflow.com/questions/27342715/blend-uicolors-in-swift
    static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        let total = intensity1 + intensity2
        let l1 = intensity1 / total
        let l2 = intensity2 / total
        guard l1 > 0 else {
            return color2
        }
        guard l2 > 0 else {
            return color1
        }
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(red: l1 * r1 + l2 * r2, green: l1 * g1 + l2 * g2, blue: l1 * b1 + l2 * b2, alpha: l1 * a1 + l2 * a2)
    }

    // https://stackoverflow.com/questions/746899/how-to-calculate-an-rgb-colour-by-specifying-an-alpha-blending-amount
    func alpha(_ alpha: CGFloat, over: UIColor = .white) -> UIColor {
        let rOriginal = cgColor.components![0] * 255
        let gOriginal = cgColor.components![1] * 255
        let bOriginal = cgColor.components![2] * 255
        var rOver: CGFloat!
        var gOver: CGFloat!
        var bOver: CGFloat!
        if over.cgColor.components!.count == 2 {
            rOver = over.cgColor.components![0] * 255
            gOver = over.cgColor.components![0] * 255
            bOver = over.cgColor.components![0] * 255
        } else if over.cgColor.components!.count >= 3 {
            rOver = over.cgColor.components![0] * 255
            gOver = over.cgColor.components![1] * 255
            bOver = over.cgColor.components![2] * 255
            if over.cgColor.components!.count >= 4 {
                bOver = over.cgColor.components![2] * 255
            }
        }
        let oneminusalpha = 1 - alpha
        let newR = ((rOriginal * alpha) + (oneminusalpha * rOver))
        let newG = ((gOriginal * alpha) + (oneminusalpha * gOver))
        let newB = ((bOriginal * alpha) + (oneminusalpha * bOver))
        return UIColor.colorFromRGBString("\(Int(newR)),\(Int(newG)),\(Int(newB))")
    }

    func alpha(_ alpha: CGFloat) -> UIColor {
        // swiftlint:disable random_rule_1
        withAlphaComponent(alpha)
        // swiftlint:enable random_rule_1
    }

    var inverse: UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        return .black // Return a default colour
    }

    static var random: UIColor {
        func random() -> CGFloat { CGFloat.random(in: 0...1) }
        return UIColor(red: random(), green: random(), blue: random(), alpha: 1.0)
    }

    var staticColor: UIColor {
        resolvedColor(with: .current)
    }

    static func colorFromHexString(_ hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        if let cachedValue = ColorsCache.shared.get(key: hexString) as? UIColor {
            return cachedValue
        }

        let hexString = hexString.replacingOccurrences(of: "#", with: "")
        var hexValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&hexValue)

        let red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexValue & 0x0000FF) / 255.0

        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        ColorsCache.shared.add(object: color, withKey: hexString)

        return color
    }

    static func colorFromRGBString(_ rgb: String) -> UIColor {
        guard !rgb.isEmpty else {
            return .black
        }

        if let cachedValue = ColorsCache.shared.get(key: rgb) as? UIColor {
            return cachedValue
        }

        let trimmedRGB = rgb.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ";", with: ",")
        let components = trimmedRGB.split(separator: ",")

        guard components.count >= 3 else {
            return colorFromHexString(rgb)
        }

        let red = CGFloat(components[0].description.floatValue ?? 0) / 255.0
        let green = CGFloat(components[1].description.floatValue ?? 0) / 255.0
        let blue = CGFloat(components[2].description.floatValue ?? 0) / 255.0

        let alpha: CGFloat = (components.count == 4) ? CGFloat(components[3].description.floatValue ?? 1) : 1

        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        ColorsCache.shared.add(object: color, withKey: rgb)

        return color
    }
}

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        let safeHex = hex.hasPrefix("#") ? hex.uppercased() : "#\(hex.uppercased())"
        let start = safeHex.index(safeHex.startIndex, offsetBy: 1)
        let hexColor = String(safeHex[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            if hexColor.count == 8 {
                a = CGFloat(hexNumber & 0x000000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: a)
            } else {
                self.init(red: r, green: g, blue: b, alpha: 1)
            }
            return
        }
        return nil
    }
}

private extension UIColor {
    private struct ColorsCache {
        private init() {}
        public static let shared = ColorsCache()
        @PWThreadSafe private var _cache = NSCache<NSString, AnyObject>()
        public func add(object: AnyObject, withKey: String) {
            // objc_sync_enter(cache); defer { objc_sync_exit(cache) }
            _cache.setObject(object as AnyObject, forKey: withKey as NSString)
        }

        public func get(key: String) -> AnyObject? {
            // objc_sync_enter(cache); defer { objc_sync_exit(_cache) }
            if let object = _cache.object(forKey: key as NSString) {
                return object
            }
            return nil
        }
    }
}
