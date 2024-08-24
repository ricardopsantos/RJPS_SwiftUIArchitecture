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
        var prefix = ""
        if favorite {
            prefix = ""
        }
        if archived {
            prefix = "🔒 "
        }
        let suffix = category == .none ? "" : " | \(category.localized)"
        return "\(prefix)\(name)\(suffix)"
    }

    var localizedEventsCount: String {
        let count = cascadeEvents?.count ?? 0
        if count > 0, let cascadeEvents = cascadeEvents, let last = cascadeEvents.max(by: { $0.recordDate > $1.recordDate }) {
            return "\(count)x, last: \(last.recordDate.dateMediumTimeShort)"
        } else {
            return ""
        }
    }
}

public extension Model.TrackedLog {
    var localizedListItemTitle: String {
        var acc = ""
        if recordDate.wasLessThan(secondsAgo: 60) {
            acc += recordDate.dateMediumTimeLong
        } else {
            acc += recordDate.dateMediumTimeShort
        }

        return acc
    }

    var localizedListItemValue: String {
        var acc = ""
        if !note.isEmpty {
            acc += note
        }
        if latitude != 0 && longitude != 0 {
            acc += "\nLocation: \(latitude)|\(longitude)"
        }
        return acc
    }
}
