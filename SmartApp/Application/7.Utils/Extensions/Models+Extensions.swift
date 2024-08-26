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
        if locationRelevant {
            prefix += "📍 "
        }
        if favorite {
            prefix += ""
        }
        if archived {
            prefix += "🔒 "
        }
        var suffix = ""
        suffix += category == .none ? "" : " | \(category.localized)"
        return "\(prefix)\(name)\(suffix)".dropLastIf("\n")
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
    var localizedListItemTitleV1: String {
        var acc = ""
        acc += recordDate.dateMediumTimeShort
        return acc.dropLastIf("\n")
    }

    var localizedListItemValueV1: String {
        var acc = ""
        if !note.isEmpty {
            acc += "◦ " + note + "\n"
        }
        if !addressMin.isEmpty {
            acc += "◦ " + "\(addressMin)"
        }
        return acc.dropLastIf("\n")
    }

    func localizedListItemTitleV2(cascadeTrackedEntity: Model.TrackedEntity?) -> String {
        if let cascadeTrackedEntity = cascadeTrackedEntity {
            var suffix = ""
            suffix += cascadeTrackedEntity.category == .none ? "" : " | \(cascadeTrackedEntity.category.localized)"
            return "\(cascadeTrackedEntity.name)\(suffix)"
        }
        return ""
    }

    var localizedListItemValueV2: String {
        var acc = ""
        acc += "◦ " + recordDate.dateMediumTimeShort + "\n"
        if !note.isEmpty {
            acc += "◦ " + note + "\n"
        }
        if !addressMin.isEmpty {
            acc += "◦ " + "\(addressMin)"
        }
        return acc.dropLastIf("\n")
    }
}
