//
//  String+Extensions.swift
//  SmartApp
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation

public extension String {
    var localized: String { NSLocalizedString(self, comment: "") }
    var localizedMissing: String {
        self
    }
}
