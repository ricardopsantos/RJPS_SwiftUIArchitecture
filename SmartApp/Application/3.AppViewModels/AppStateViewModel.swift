//
//  AppStateManager.swift
//  Core
//
//  Created by Ricardo Santos on 21/07/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Core
import Common

public final class AppStateViewModel: ObservableObject {
    // MARK: - Dependency Attributes

    // MARK: - Usage Attributes
    @AppStorage(NonSecureAppPreferencesKey.userPIN.rawValue) public var userPIN: String = "22222"
    @PWUserDefaults(value: "", key: NonSecureAppPreferencesKey.userName.rawValue) var userName: String

    // MARK: - Auxiliar Attributes
    private var cancelBag: CancelBag = .init()

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
