//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

//
// MARK: - Transformations / Operators
//

private extension String {
    private var cleanBeforeConversion: String {
        replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
    }
}

public extension String {
    var random: String { String.random(Int.random(in: 10...100)) }
    var length: Int { count }
    var first: String { String(prefix(1)) }
    var last: String { if isEmpty {
        ""
    } else {
        String(suffix(1))
    } }

    var trim: String { // Trim and single spaces
        replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var onlyWhiteSpace: String { // String with only white spaces return ""
        trimmingCharacters(in: .whitespaces) != "" ? self : ""
    }

    var multipleWhiteSpace: String { // String with more than one space return ""
        replacingOccurrences(of: "  ", with: " ", options: .regularExpression)
    }

    /// is_conformity_validated -> Is Conformity Validated
    var fromSnakeCaseToHumanFriendly: String {
        guard contains("_") else {
            return self
        }
        let components = components(separatedBy: "_")
        let capitalizedComponents = components.map(\.capitalized)
        let message = capitalizedComponents.joined(separator: " ")
        return message
    }

    var encodedUrl: String? { addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) }
    var decodedUrl: String? { removingPercentEncoding }
    var reversed: String { var acc = ""; for char in self { acc = "\(char)\(acc)" }; return acc }

    var dateValueISO8601UTC: Date? {
        // swiftlint:disable no_hardCodedTimeZones
        Date.with(
            self,
            dateFormat: DateFormatter.MainFormats.iso8601UTC.value,
            timeZoneIdentifier: "UTC"
        )
        // swiftlint:enable no_hardCodedTimeZones
    }

    var dateValueISO8601: Date? {
        Date.with(
            self,
            dateFormat: DateFormatter.MainFormats.iso8601.value
        )
    }

    var dateValueISO8601Almost: Date? {
        Date.with(
            self,
            dateFormat: DateFormatter.MainFormats.iso8601Almost.value
        )
    }

    var dateValue: Date? { dateValueISO8601 }
    var dates: [Date]? {
        var nsRange: NSRange { NSRange(location: 0, length: length) }
        return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            .matches(in: self, range: nsRange)
            .compactMap(\.date)
    }

    var isValidInt: Bool {
        // Only allow numbers. Look for anything not a number.
        rangeOfCharacter(from: NSCharacterSet.decimalDigits.inverted) == nil
    }

    var numberValue: NSNumber? { NumberFormatter().number(from: cleanBeforeConversion.replace(",", with: ".")) }
    var utf8Data: Data? { data(using: .utf8) }
    var boolValue: Bool? {
        if let some = cleanBeforeConversion.numberValue {
            return Bool(truncating: some)
        }
        return Bool((self as NSString).boolValue)
    }

    var intValue: Int? {
        if let some = cleanBeforeConversion.numberValue {
            return Int(truncating: some)
        }
        return Int((self as NSString).intValue)
    }

    var doubleValue: Double? {
        if let some = cleanBeforeConversion.numberValue {
            return Double(truncating: some)
        }
        return Double((self as NSString).doubleValue)
    }

    var cgFloatValue: CGFloat? {
        if let float = Float(self), float > 0 {
            return CGFloat(float)
        }
        if let some = cleanBeforeConversion.numberValue {
            return CGFloat(truncating: some)
        }
        return CGFloat((self as NSString).floatValue)
    }

    var floatValue: Float? {
        if let some = cleanBeforeConversion.numberValue {
            return Float(truncating: some)
        }
        return Float((self as NSString).floatValue)
    }

    var decimalValue: Decimal? {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let groupingSeparator = Locale.current.groupingSeparator ?? ","
        let regex: NSRegularExpression! = try? NSRegularExpression(pattern: "[^0-9\(decimalSeparator)]", options: .caseInsensitive)
        var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.decimalSeparator = decimalSeparator
            formatter.groupingSeparator = groupingSeparator
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter
        }
        let regexedString = regex.stringByReplacingMatches(
            in: self,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSRange(location: 0, length: count),
            withTemplate: ""
        )

        return formatter.number(from: regexedString)?.decimalValue
    }
}

//
// MARK: - Hashing
//

public extension String {
    // Generates a deterministic hash value for the string.
    // This method uses a custom hashing algorithm by combining UTF-8 values of the characters
    // with a sequence of multipliers. The zip function pairs each UTF-8 character with a multiplier
    // in the sequence, then maps and reduces the results to produce a final hash value.
    var deterministicHashValue: Int {
        zip(utf8.map(numericCast), Swift.sequence(first: 1, next: { $0 &* 589836 })).map(&*).reduce(0, &+)
    }

    // Computes the SHA-1 hash of the string.
    // This method converts the string into a UTF-8 data representation, then computes the SHA-1
    // hash of the data. The resulting digest is an array of bytes, which is then converted to a
    // hexadecimal string.
    var sha1: String {
        let data = Data(utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

//
// MARK: - Constructors
//

public extension String {
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}

//
// MARK: - Bools
//

extension String? {
    var nullOrEmpty: Bool {
        !(self == nil || self!.isEmpty)
    }
}

public extension String {
    // Found at https://medium.com/@darthpelo/email-validation-in-swift-3-0-acfebe4d879a
    var isValidEmail: Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    var isOnlyDigits: Bool {
        let notDigits = NSCharacterSet.decimalDigits.inverted
        return rangeOfCharacter(from: notDigits, options: String.CompareOptions.literal, range: nil) == nil
    }

    func countOccurrences(of substring: String) -> Int {
        let components = components(separatedBy: substring)
        return components.count - 1
    }

    func contains(_ subString: String, ignoreCase: Bool = true) -> Bool {
        if ignoreCase {
            lowercased().range(of: subString.lowercased()) != nil
        } else {
            range(of: subString) != nil
        }
    }
}

//
// MARK: - Utils
//

public extension CustomStringConvertible where Self: Codable {
    var description: String {
        var description = "\n \(type(of: self)) \n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)\n"
            }
        }
        return description
    }
}

public extension String {
    var capitalised: String { count >= 1 ? prefix(1).uppercased() + lowercased().dropFirst() : "" }

    /// equipmentAfterIntervention  -> Equipment after intervention
    var camelCaseToWords: String {
        let pattern = "([a-z])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        let modifiedString = regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1 $2")
        let capitalizedString = modifiedString?.capitalized
        return capitalizedString ?? ""
    }

    ///  equipment-after-intervention  -> Equipment after intervention
    var toTitleCase: String {
        let words = replace("_", with: "-").components(separatedBy: "-")
        let titleCaseWords = words.map { word -> String in
            let firstLetter = word.prefix(1).capitalized
            let remainingLetters = word.dropFirst()
            return firstLetter + remainingLetters
        }
        return titleCaseWords.joined(separator: " ")
    }

    /// Premier League -> PL, La Liga -> LL
    var abbreviate: String {
        let words = components(separatedBy: " ")
        var abbreviation = ""
        for word in words {
            if let firstCharacter = word.first {
                abbreviation.append(String(firstCharacter).uppercased())
            }
        }
        return abbreviation
    }

    func superscriptLastCharacter(font: UIFont) -> NSMutableAttributedString {
        let superscriptAtttributedString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        if let superscriptFont = UIFont(name: font.fontName, size: font.pointSize * 0.6) {
            superscriptAtttributedString.setAttributes(
                [
                    NSAttributedString.Key.font: superscriptFont,
                    NSAttributedString.Key.baselineOffset: font.lineHeight * 0.3
                ],
                range: NSRange(location: count - 1, length: 1)
            )
        }
        return superscriptAtttributedString
    }

    func dropFirstIf(_ some: String) -> String {
        if hasPrefix(some) {
            return "\(dropFirst(some.count))"
        } else {
            return self
        }
    }

    func dropLastIf(_ some: String) -> String {
        if hasSuffix(some) {
            return "\(dropLast(some.count))"
        } else {
            return self
        }
    }

    // let json = "{\"hello\": \"world\"}"
    // let dictFromJson = json.asDict
    var asDict: [String: Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }

    var isHTMLString: Bool {
        let htmlTags = ["<html", "<head", "<body", "<div", "<p", "<span", "<a", "<img", "<table", "<ul", "<ol"]
        for tag in htmlTags {
            if contains(tag) {
                return true
            }
        }
        return false
    }

    var escapedHTML: String {
        let mappings = [
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;",
            "\"": "&quot;",
            "'": "&#x27;",
            "`": "&#x60;",
            " ": "&nbsp;"
        ]

        var result = self
        for (a, b) in mappings {
            result = result.replacingOccurrences(of: b, with: a)
        }
        return result
    }

    // let htmlString = "<p>Hello, <strong>world!</string></p>"
    // let attrString = htmlString.asAttributedString
    var asAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }

    func image(font: UIFont, size: CGSize = CGSize(width: 40, height: 40)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: font])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func split(by: String) -> [String] {
        guard !by.isEmpty else {
            return []
        }
        return components(separatedBy: by)
    }

    static func random(_ length: Int, haveSpaces: Bool = false) -> String {
        var letters: NSString!
        if haveSpaces {
            letters = "          abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        } else {
            letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        }
        var randomString = ""
        for _ in 0..<length {
            let rand = Int.random(in: 0...letters.length - 1)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

    static func randomWithSpaces(_ length: Int) -> String {
        random(length, haveSpaces: true)
    }

    func replace(_ some: String, with: String) -> String {
        guard !some.isEmpty else {
            return self
        }
        return replacingOccurrences(of: some, with: with)
    }

    func htmlAttributedString(fontName: String, fontSize: Int, colorHex: String) -> NSAttributedString? {
        do {
            let cssPrefix = "<style>* { font-family: \(fontName); color: #\(colorHex); font-size: \(fontSize); }</style>"
            let html = cssPrefix + self
            guard let data = html.data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            Common_Logs.error("\(error)")
            return nil
        }
        /**
         ```
         let test = {
         let html = "<strong>Dear Friend</strong> I hope this <i>tip</i> will be useful for <b>you</b>."
         let attributedString = html.htmlAttributedString(with: "Futura", fontSize: 14, colorHex: "ff0000")

         }
         test()
         ```
         */
    }
}

public extension String {
    /// _10 min_ -> _10_
    var extrateMinutes: Int {
        var minutes: Int = 0
        if contains(" "),
           let value = split(by: " ").first,
           let intValue = value.intValue, intValue > 0 {
            minutes = intValue
        } else if contains(" "),
                  let value = split(by: " ").last,
                  let intValue = value.intValue, intValue > 0 {
            minutes = intValue
        } else if let intValue, intValue > 0 {
            minutes = intValue
        }
        return minutes
    }
}

//
// MARK: - SubScript
//

public extension String {
    subscript(i: Int) -> String { self[i..<i + 1] }

    func substring(fromIndex: Int) -> String { self[min(fromIndex, length)..<length] }

    func substring(toIndex: Int) -> String { self[0..<max(0, toIndex)] }

    subscript(r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (
            lower: max(0, min(length, r.lowerBound)),
            upper: min(length, max(0, r.upperBound))
        ))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start..<end])
    }

    subscript(i: Int) -> Character {
        self[index(startIndex, offsetBy: i)]
    }

    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start {
            return ""
        }
        return self[start..<end]
    }

    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start {
            return ""
        }
        return self[start...end]
    }

    subscript(bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        if end < start {
            return ""
        }
        return self[start...end]
    }

    subscript(bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex {
            return ""
        }
        return self[startIndex...end]
    }

    subscript(bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex {
            return ""
        }
        return self[startIndex..<end]
    }
}
