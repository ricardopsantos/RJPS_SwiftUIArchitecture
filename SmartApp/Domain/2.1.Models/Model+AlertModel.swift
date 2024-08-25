//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
//
import DevTools
import Common

//
// MARK: - AlertType
//
public extension Model.AlertModel {
    enum AlertLocation: String, CaseIterable, Hashable, Codable {
        case top
        case bottom
        case middle
    }

    enum AlertType: String, CaseIterable, Hashable, Codable {
        case information
        case success
        case warning
        case error
    }
}

//
// MARK: - AlertModel
//
public extension Model {
    struct AlertModel {
        public let type: AlertType
        public let location: AlertLocation
        public let message: String
        public let date: Date
        public var onUserTapGesture: (() -> Void)? // Custom code to run when user tapped alert
        public var parentDismiss: (() -> Void)? // Inject code to dismiss alert externally (by parent view)

        public func onTapGesture() {
            if let onUserTapGesture = onUserTapGesture {
                onUserTapGesture()
            }
            if let parentDismiss = parentDismiss {
                parentDismiss()
            }
        }

        public init(type: AlertType, location: AlertLocation = .top, message: String, onUserTapGesture: (() -> Void)? = nil) {
            self.type = type
            self.message = message
            self.location = location
            self.onUserTapGesture = onUserTapGesture
            self.date = .now
        }
    }
}

//
// MARK: - Equatable
//
extension Model.AlertModel: Equatable {
    public static func == (lhs: Model.AlertModel, rhs: Model.AlertModel) -> Bool {
        lhs.type == rhs.type &&
            lhs.location == rhs.location &&
            lhs.message == rhs.message &&
            lhs.date == rhs.date &&
            lhs.onUserTapGesture.debugDescription == rhs.onUserTapGesture.debugDescription
    }
}

//
// MARK: - Utils
//
public extension Model.AlertModel {
    var visibleTime: CGFloat {
        let defaultTime: CGFloat = 3
        switch type {
        case .success: return defaultTime
        case .warning: return defaultTime * 1.5
        case .error: return DevTools.onSimulator ? defaultTime : defaultTime * 2
        case .information: return defaultTime
        }
    }

    static var success: Self {
        Model.AlertModel(type: .success, location: .top, message: "Success", onUserTapGesture: nil)
    }

    static var tryAgainLatter: Self {
        Model.AlertModel(type: .error, location: .top, message: "Please try again latter", onUserTapGesture: nil)
    }

    static var noInternet: Self {
        Model.AlertModel(type: .error, location: .top, message: "No internet", onUserTapGesture: nil)
    }
}
