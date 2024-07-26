//
//  AnalyticsManager.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import FirebaseAnalytics
//
import DevTools

extension AnalyticsManager {
    struct BaseEvent {
        let eventType: EventType
        var eventProperties: [String: Any] = [:]
    }

    enum EventType {
        case login
        case updateUser
        case buttonClick(type: ButtonType, label: String)

        enum ButtonType: String {
            case primary = "Primary"
            case secondary = "Secondary"
            case text = "Text"
            case back = "Back"
            case navigationTab = "Navigation Tab"
        }

        var rawValue: String {
            switch self {
            case .login, .updateUser: return "\(self)"
            case .buttonClick(type: let type, label: let label): return "buttonClick_\(type)_\(label)"
            }
        }
    }
}

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    func handleScreenIn(appScreen: AppScreen) {
        let parameters: [String: Any] = [
            AnalyticsParameterScreenName: appScreen.id.description
        ]
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }

    func handleCustomEvent(eventType: EventType, properties: [String: Any] = [:]) {
        let baseEvent = BaseEvent(eventType: eventType, eventProperties: properties)
        handle(baseEvent: baseEvent)
    }

    func handleButtonClickEvent(
        buttonType: AnalyticsManager.EventType.ButtonType = .primary,
        label: String,
        sender: String,
        properties: [String: Any] = [:]
    ) {
        DevTools.assert(!label.isEmpty, message: "Empty label")
        DevTools.assert(!sender.isEmpty, message: "Empty sender")
        var newProperties = properties
        newProperties["sender"] = sender
        let baseEvent = BaseEvent(eventType: EventType.buttonClick(type: buttonType, label: label), eventProperties: properties)
        handle(baseEvent: baseEvent)
    }
}

private extension AnalyticsManager {
    func handle(baseEvent: BaseEvent) {
        DevTools.Log.debug(.log("\(AnalyticsManager.self) : \(baseEvent.eventType)"), .business)
        Analytics.logEvent(baseEvent.eventType.rawValue, parameters: baseEvent.eventProperties)
    }
}