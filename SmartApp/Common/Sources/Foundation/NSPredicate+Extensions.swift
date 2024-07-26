//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public extension NSPredicate {
    static func allFields(_ fields: [String], with value: String, caseSensitive: Bool = false) -> NSPredicate {
        guard !value.isEmpty else { return NSPredicate(value: false) }
        if caseSensitive {
            let predicatesCaseSensitive: [NSPredicate] = fields.filter { !$0.isEmpty }.map { NSPredicate(format: "\($0) == %@", value) }
            if predicatesCaseSensitive.count >= 2 {
                return NSCompoundPredicate(type: .and, subpredicates: predicatesCaseSensitive)
            } else {
                return predicatesCaseSensitive.first ?? NSPredicate(value: false)
            }
        } else {
            let predicatesNotCaseSensitive: [NSPredicate] = fields.filter { !$0.isEmpty }.map { NSPredicate(format: "\($0) ==[c] %@", value) }
            if predicatesNotCaseSensitive.count >= 2 {
                return NSCompoundPredicate(type: .and, subpredicates: predicatesNotCaseSensitive)
            } else {
                return predicatesNotCaseSensitive.first ?? NSPredicate(value: false)
            }
        }
    }

    static func anyField(_ fields: [String], with value: String, caseSensitive: Bool = false) -> NSPredicate {
        guard !value.isEmpty else { return NSPredicate(value: false) }
        if caseSensitive {
            let predicatesCaseSensitive: [NSPredicate] = fields.filter { !$0.isEmpty }.map { NSPredicate(format: "\($0) == %@", value) }
            if predicatesCaseSensitive.count >= 2 {
                return NSCompoundPredicate(type: .or, subpredicates: predicatesCaseSensitive)
            } else {
                return predicatesCaseSensitive.first ?? NSPredicate(value: false)
            }
        } else {
            let predicatesNotCaseSensitive: [NSPredicate] = fields.filter { !$0.isEmpty }.map { NSPredicate(format: "\($0) ==[c] %@", value) }
            if predicatesNotCaseSensitive.count >= 2 {
                return NSCompoundPredicate(type: .or, subpredicates: predicatesNotCaseSensitive)
            } else {
                return predicatesNotCaseSensitive.first ?? NSPredicate(value: false)
            }
        }
    }

    static func anyField(_ fields: [String], thatContains value: String) -> NSPredicate? {
        let filterEscaped = value.trim
        guard !filterEscaped.isEmpty else {
            return nil
        }
        // We have something to search...
        var predicatesList = [NSPredicate]()
        let words = value.split(by: " ")
        func predicateFor(word: String) -> NSPredicate {
            var format: String = ""
            fields.forEach { field in
                format = "\(format) \(field) contains[cd] %@ OR"
            }
            format = format.dropLastIf(" OR")
            if words.count > 10 {
                fatalError("Only works till 10 words")
            }
            return NSPredicate(format: format, word, word, word, word, word, word, word, word, word, word)
        }
        words.forEach { word in
            // Search several words
            if !word.trim.isEmpty {
                predicatesList.append(predicateFor(word: word.trim))
            }
        }
        if predicatesList.count >= 2 {
            return NSCompoundPredicate(type: .and, subpredicates: predicatesList)
        } else {
            return predicatesList.first
        }
    }
}

extension NSPredicate {
    // Create a predicate that checks if a field contains a specific substring
    static func contains(_ keyPath: String, substring: String) -> NSPredicate {
        NSPredicate(format: "%K CONTAINS[cd] %@", keyPath, substring)
    }

    // Create a predicate that checks if a field starts with a specific substring
    static func beginsWith(_ keyPath: String, substring: String) -> NSPredicate {
        NSPredicate(format: "%K BEGINSWITH[cd] %@", keyPath, substring)
    }

    // Create a predicate that checks if a field ends with a specific substring
    static func endsWith(_ keyPath: String, substring: String) -> NSPredicate {
        NSPredicate(format: "%K ENDSWITH[cd] %@", keyPath, substring)
    }

    // Create a predicate that checks if a field matches a regular expression
    static func matches(_ keyPath: String, regex: String) -> NSPredicate {
        NSPredicate(format: "%K MATCHES %@", keyPath, regex)
    }

    // Create a predicate that checks if a field is equal to a specific value
    static func isEqual(_ keyPath: String, value: Any) -> NSPredicate {
        NSPredicate(format: "%K == %@", keyPath, value as! CVarArg)
    }

    // Create a predicate that checks if a field is greater than a specific value
    static func isGreaterThan(_ keyPath: String, value: Any) -> NSPredicate {
        NSPredicate(format: "%K > %@", keyPath, value as! CVarArg)
    }

    // Create a predicate that checks if a field is less than a specific value
    static func isLessThan(_ keyPath: String, value: Any) -> NSPredicate {
        NSPredicate(format: "%K < %@", keyPath, value as! CVarArg)
    }

    // Create a predicate that checks if a field is between two specific values
    static func isBetween(_ keyPath: String, minValue: Any, maxValue: Any) -> NSPredicate {
        NSPredicate(format: "%K >= %@ AND %K <= %@", keyPath, minValue as! CVarArg, keyPath, maxValue as! CVarArg)
    }
}
