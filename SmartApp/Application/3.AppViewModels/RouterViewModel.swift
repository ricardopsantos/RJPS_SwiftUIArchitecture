//
//  RouterViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Foundation
import SwiftUI

public final class RouterViewModel: ObservableObject {
    // MARK: - Dependency Attributes

    // MARK: - Usage Attributes
    @Published var navPath = NavigationPath()
    @Published var sheetLink: AppScreen?
    @Published var coverLink: AppScreen?

    // MARK: - Auxiliar Attributes
    // private var cancelBag: CancelBag = .init()

    // MARK: - Constructor

    public init() {}

    // MARK: - Functions

    public func navigate(to appScreen: AppScreen) {
        navPath.append(appScreen)
    }

    public func navigate(to destination: any Hashable) {
        navPath.append(destination)
    }

    public func navigateBack() {
        if !navPath.isEmpty {
            navPath.removeLast()
        }
    }

    public func navigateToRoot() {
        if !navPath.isEmpty {
            navPath.removeLast(navPath.count)
        }
    }
}

extension RouterViewModel: Equatable {
    public static func == (lhs: RouterViewModel, rhs: RouterViewModel) -> Bool {
        lhs.navPath == rhs.navPath &&
            lhs.sheetLink == rhs.sheetLink &&
            lhs.coverLink == rhs.coverLink
    }
}
