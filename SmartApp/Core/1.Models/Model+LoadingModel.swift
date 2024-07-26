//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Common

public enum LoadingModelDisplayType: Int {
    case innerTopRightSmallLoading
    case notOverCurrentContextCenter
    case overCurrentContext

    public static var `default`: LoadingModelDisplayType {
        .notOverCurrentContextCenter
    }
}

public extension Model {
    struct LoadingModel: ModelProtocol {
        public let isLoading: Bool
        public let displayTypeRaw: Int
        public let message: String
        public let id: String

        var displayType: LoadingModelDisplayType {
            LoadingModelDisplayType(rawValue: displayTypeRaw) ?? .default
        }

        fileprivate init(
            isLoading: Bool,
            message: String = "",
            id: String,
            displayType: LoadingModelDisplayType = .default
        ) {
            self.isLoading = isLoading
            self.message = message
            self.id = id
            self.displayTypeRaw = displayType.rawValue
        }

        public static var notLoading: LoadingModel {
            LoadingModel(isLoading: false, message: "", id: "")
        }

        public static func loading(
            _ displayType: LoadingModelDisplayType = LoadingModelDisplayType.default,
            message: String,
            id: String = UUID().uuidString
        ) -> LoadingModel {
            LoadingModel(isLoading: true, message: message, id: id, displayType: displayType)
        }
    }
}
