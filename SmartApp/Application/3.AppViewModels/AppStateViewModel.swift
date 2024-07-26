//
//  AppStateManager.swift
//  Core
//
//  Created by Ricardo Santos on 21/07/2024.
//

import Foundation
import SwiftUI
//
import Core
import Common

public final class AppStateViewModel: ObservableObject {
    // MARK: - Dependency Attributes

    // MARK: - Usage Attributes
    @AppStorage(NonSecureAppPreferences.Key.userPIN.rawValue) public var userPIN: String = "22222"
    @PWUserDefaults(value: "", key: NonSecureAppPreferences.Key.userName.rawValue) var userName: String

    // MARK: - Constructor
    init() {}

    // MARK: - Functions
}

// MARK: - Previews

extension AppStateViewModel {
    static var defaultForPreviews: AppStateViewModel {
        .init()
    }
}
