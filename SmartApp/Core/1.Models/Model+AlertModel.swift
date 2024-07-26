//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Common

public extension Model {
    struct AlertModel: Equatable {
        public static func == (lhs: AlertModel, rhs: AlertModel) -> Bool {
            lhs.type == rhs.type &&
                lhs.message == rhs.message &&
                lhs.onDismiss.debugDescription == rhs.onDismiss.debugDescription
        }

        public enum AlertType: CaseIterable, Hashable, Codable {
            case information
            case success
            case warning
            case error
        }

        public let type: AlertType
        public let message: String
        public var onDismiss: (() -> Void)?

        public init(type: AlertType, message: String, onDismiss: (() -> Void)? = nil) {
            self.type = type
            self.message = message
            self.onDismiss = onDismiss
        }

        public static var success: AlertModel {
            AlertModel(type: .success, message: "Success" /* .localizedMissing */, onDismiss: {})
        }

        public static var tryAgainLatter: AlertModel {
            AlertModel(type: .error, message: "Please try again latter" /* .localizedMissing */, onDismiss: {})
        }

        public static var noInternet: AlertModel {
            AlertModel(type: .error, message: "No internet" /* .localizedMissing */, onDismiss: {})
        }
    }
}
