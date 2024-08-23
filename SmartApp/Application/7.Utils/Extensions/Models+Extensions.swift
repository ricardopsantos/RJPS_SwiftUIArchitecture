//
//  Models+Extensions.swift
//  SmartApp
//
//  Created by Ricardo Santos on 22/08/2024.
//

import Foundation
//
import Common
import Domain

public extension Model.TrackedEntity {
    var localizedEventName: String {
        "Name: \(name)"
    }

    var localizedEventsCount: String {
        let count = cascadeEvents?.count ?? 0
        return "Events: \(count.localeString)".localizedMissing
    }
}

public extension Model.TrackedLog {
    var localizedListItemTitle: String {
        var acc = ""
        acc += "Note: ".localizedMissing + note + "\n"
        acc += "Date: ".localizedMissing + recordDate.dateMediumTimeShort
        return acc
    }

    var localizedListItemValue: String {
        "Location: \(latitude)|\(longitude)"
    }
}
