//
//  NavigationModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/08/2024.
//

import Foundation

extension BaseView {
    struct NavigationViewModel: Equatable {
        public static func == (lhs: NavigationViewModel, rhs: NavigationViewModel) -> Bool {
            lhs.type == rhs.type &&
                lhs.title == rhs.title &&
                lhs.onBackButtonTap.debugDescription == rhs.onBackButtonTap.debugDescription
        }

        public enum NavigationModelType: CaseIterable, Hashable, Codable {
            case none
            case enabled
        }

        public let type: NavigationModelType
        public let title: String
        public var onBackButtonTap: (() -> Void)?

        private init(type: NavigationModelType, title: String, onBackButtonTap: (() -> Void)?) {
            self.type = type
            self.title = title
            self.onBackButtonTap = onBackButtonTap
        }

        public static var disabled: Self {
            .init(type: .none, title: "", onBackButtonTap: nil)
        }

        public static func enabled(onBackButtonTap: @escaping (() -> Void), title: String) -> Self {
            .init(type: .enabled, title: title, onBackButtonTap: onBackButtonTap)
        }
    }
}
