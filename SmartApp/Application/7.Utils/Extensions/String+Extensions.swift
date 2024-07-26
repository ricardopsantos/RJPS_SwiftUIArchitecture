//
//  String+Extensions.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation

extension String {
    var nilIfEmpty: String? {
        self == "" ? nil : self
    }

    func formattedDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}

extension String? {
    func isNotNullOrEmpty() -> Bool {
        !(self == nil || self!.isEmpty)
    }
}

public extension String {
    var localized: String { NSLocalizedString(self, comment: "") }

    var localizedMissing: String {
        self
    }
}
