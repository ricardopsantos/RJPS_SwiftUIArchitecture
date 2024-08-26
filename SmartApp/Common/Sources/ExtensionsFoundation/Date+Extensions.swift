//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension TimeInterval {
    static let oneYear: Self = .init(60 * 60 * 24 * 365)
    static let oneWeek: Self = .init(60 * 60 * 24 * 7)
    var hourMinuteSecondMS: String { String(format: "%d:%02d:%02d.%03d", hour, minute, second, millisecond) }
    var minuteSecondMS: String { String(format: "%d:%02d.%03d", minute, second, millisecond) }
    var hour: Int { Int((self / 3600).truncatingRemainder(dividingBy: 3600)) }
    var minute: Int { Int((self / 60).truncatingRemainder(dividingBy: 60)) }
    var second: Int { Int(truncatingRemainder(dividingBy: 60)) }
    var millisecond: Int64 { Int64((self * 1000).truncatingRemainder(dividingBy: 1000)) }
}

public extension DateFormatter {
    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = MainFormats.monthAndYear.rawValue
        return formatter
    }

    enum MainFormats: String {
        case iso8601 = "yyyy-MM-dd'T'HH:mm:ssXXX" /// XXX: Time zone offset in the format ±HH:mm (e.g., +05:00)
        case iso8601UTC = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'" /// SSSSSS: Fractional seconds (microseconds, e.g., 123456),  'Z' indicating UTC time
        case iso8601Almost = "yyyy-MM-dd HH:mm:ss"
        case monthAndYear = "MMMM yyyy"
        public var value: String {
            rawValue
        }
    }
}

public extension Date {
    var toISO8601String: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.MainFormats.iso8601.value
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Use POSIX locale for consistent formatting
        return dateFormatter.string(from: self)
    }

    static var userDate: Date { Date() }
    static var utcNow: Date { Date() }
    static var systemDate: Date { Date() }

    init(string: String) {
        self = Date.with(string) ?? Date.utcNow
    }

    private static var defaultDateFormatter: DateFormatter {
        DateFormatter()
    }

    static func withInternetDateTime(
        _ dateToParse: String
    ) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter.date(from: dateToParse) ?? Date()
    }

    static func with(
        _ dateToParse: String,
        dateFormat: String = DateFormatter.MainFormats.iso8601.value,
        timeZoneIdentifier: String? = TimeZone.current.identifier
    ) -> Date? {
        guard dateToParse != "null" else {
            return nil
        }
        guard dateToParse != "nil" else {
            return nil
        }
        guard !dateToParse.trim.isEmpty else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateFormat // http://userguide.icu-project.org/formatparse/datetime
        if let timeZoneIdentifier = timeZoneIdentifier {
            dateFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        }
        if let date = dateFormatter.date(from: dateToParse) {
            return date
        }
        if let date = dateToParse.dates?.first {
            return date
        }
        if let unixTimestamp = dateToParse.doubleValue, unixTimestamp > 0 {
            return Date(timeIntervalSince1970: unixTimestamp)
        }
        return nil
    }

    var timeStyleShort: String {
        let formatter = Self.defaultDateFormatter
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: self)
    }

    var monthAndYear: String {
        let formatter = DateFormatter.monthAndYear
        return formatter.string(from: self)
    }

    var timeStyleMedium: String {
        let formatter = Self.defaultDateFormatter
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: self)
    }

    var dateMediumTimeLong: String {
        let formatter = Self.defaultDateFormatter
        formatter.timeStyle = .long
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var dateMediumTimeShort: String {
        let formatter = Self.defaultDateFormatter
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var dateShortTimeShort: String {
        let formatter = Self.defaultDateFormatter
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }

    var dateStyleMedium: String {
        let formatter = Self.defaultDateFormatter
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var dateStyleShort: String {
        let formatter = Self.defaultDateFormatter
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }

    var isToday: Bool { day == Date.userDate.day && month == Date.userDate.month && year == Date.userDate.year }
    var isYesterday: Bool {
        let yesterday = Date.userDate.add(days: -1)
        return day == yesterday.day && month == yesterday.month && year == yesterday.year
    }

    var seconds: Int { ((Calendar.current as NSCalendar).components([.second], from: self).second)! }
    var minutes: Int { ((Calendar.current as NSCalendar).components([.minute], from: self).minute)! }
    var hours: Int { ((Calendar.current as NSCalendar).components([.hour], from: self).hour)! }
    var day: Int { ((Calendar.current as NSCalendar).components([.day], from: self).day)! }
    var month: Int { ((Calendar.current as NSCalendar).components([.month], from: self).month)! }
    var year: Int { ((Calendar.current as NSCalendar).components([.year], from: self).year)! }
    var weekDay: Int { ((Calendar.current as NSCalendar).components([.weekday], from: self).weekday)! }

    func add(days: Int) -> Date { add(hours: days * 24) }
    func add(hours: Int) -> Date { add(minutes: hours * 60) }
    func add(minutes: Int) -> Date { add(seconds: minutes * 60) }
    func add(seconds: Int) -> Date { NSCalendar.current.date(byAdding: .second, value: seconds, to: self)! }
    func add(month: Int) -> Date { NSCalendar.current.date(byAdding: .month, value: month, to: self)! }
    func add(years: Int) -> Date { NSCalendar.current.date(byAdding: .year, value: years, to: self)! }
    func set(month: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.month = month
        guard let newDate = Calendar.current.date(from: components) else {
            return self
        }
        return newDate
    }

    func set(day: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.day = day
        guard let newDate = Calendar.current.date(from: components) else {
            return self
        }
        return newDate
    }

    func set(hour: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hour >= 24 ? 0 : hour,
            minute: minutes,
            second: seconds,
            of: self
        )!
    }

    func set(minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hours,
            minute: minute >= 60 ? 0 : minute,
            second: seconds,
            of: self
        )!
    }

    func set(second: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hours,
            minute: minutes,
            second: second >= 60 ? 0 : second,
            of: self
        )!
    }

    var beginningOfDay: Date? {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }

    var endOfDay: Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = 1
        components.second = -1
        if let beginningOfDay = beginningOfDay {
            return calendar.date(byAdding: components, to: beginningOfDay)
        } else {
            return nil
        }
    }

    var beginningOfMonth: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)
    }

    var endOfMonth: Date? {
        let calendar = Calendar.current
        if let startOfMonth = beginningOfMonth {
            var components = DateComponents()
            components.month = 1
            components.second = -1
            return calendar.date(byAdding: components, to: startOfMonth)
        }
        return nil
    }

    func isBiggerThan(_ dateToCompare: Date) -> Bool {
        compare(dateToCompare) == ComparisonResult.orderedDescending
    }

    func wasLessThan(secondsAgo: Int, refDate: Date) -> Bool {
        !isBiggerThan(refDate.add(seconds: seconds))
    }

    func wasLessThan(secondsAgo: Int) -> Bool {
        wasLessThan(secondsAgo: secondsAgo, refDate: Date())
    }

    func timeAgoString(resources: [String] = [
        "sec(s) ago",

        "min(s) ago",
        "hr(s) ago",
        "day(s) ago",
        "week(s) ago",
        "month(s) ago",
        "year(s) ago"
    ]) -> String {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(self)
        func timeAgoString(from timeInterval: TimeInterval) -> String {
            let seconds = Int(timeInterval)
            let minutes = seconds / 60
            let hours = minutes / 60
            let days = hours / 24
            let weeks = days / 7
            let months = days / 30
            let years = days / 365
            if years > 0 {
                return "\(years) \(resources[7])"
            } else if months > 0 {
                return "\(months) \(resources[6])"
            } else if weeks > 0 {
                return "\(weeks) \(resources[5])"
            } else if days > 0 {
                return "\(days) \(resources[3])"
            } else if hours > 0 {
                return "\(hours) \(resources[2])"
            } else if minutes > 0 {
                return "\(minutes) \(resources[1])"
            } else {
                return "\(seconds) \(resources[0])"
            }
        }
        return timeAgoString(from: timeInterval)
    }

    /// Get next specific day of week.
    ///
    /// If you need to know what day it is next Sunday, just enter the day of the week.
    /// Weekday numbers to return specific day:
    /// Sunday = 1, Monday = 2, Tuesday = 3, Wednesday = 4, Thursday = 5, Friday = 6, Saturday = 7.
    /// - Warning: 0 or numbers greater than 7 will crash the app.
    func getNextSpecificDayOfWeek(
        _ weekday: Int,
        direction: Calendar.SearchDirection = .forward,
        considerToday: Bool = false
    ) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(weekday: weekday)

        if considerToday, calendar.component(.weekday, from: self) == weekday {
            return self
        }
        return calendar.nextDate(after: self, matching: components, matchingPolicy: .nextTime, direction: direction)!
    }
}
