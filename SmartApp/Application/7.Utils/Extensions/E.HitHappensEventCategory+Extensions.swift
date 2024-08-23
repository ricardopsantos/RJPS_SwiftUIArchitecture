//
//  HitHappensEventCategory+Extensions.swift
//  SmartApp
//
//  Created by Ricardo Santos on 22/08/2024.
//

import Foundation
//
import Domain

extension HitHappensEventCategory {
    var localized: String {
        switch self {
        case .none: return "None".localizedMissing
        case .health: return "Health".localizedMissing
        case .lifestyle: return "Lifestyle".localizedMissing
        case .professional: return "Professional".localizedMissing
        case .personal: return "Personal".localizedMissing
        }
    }
}
