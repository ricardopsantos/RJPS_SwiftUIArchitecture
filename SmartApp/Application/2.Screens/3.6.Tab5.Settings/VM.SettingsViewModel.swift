//
//  SettingsViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

//
// MARK: - Model
//

struct SettingsModel: Equatable, Hashable, Sendable {
    let some: Bool
    init(some: Bool = false) {
        self.some = some
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension SettingsViewModel {
    enum Actions {
        case didAppear
        case didDisappear
    }

    struct Dependencies {
        let model: SettingsModel
        let onShouldDisplayEditUserDetails: () -> Void
        let authenticationViewModel: AuthenticationViewModel
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
        let userRepository: UserRepositoryProtocol
    }
}

class SettingsViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    private var cancelBag = CancelBag()
    private let authenticationViewModel: AuthenticationViewModel?
    private let nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    private let userRepository: UserRepositoryProtocol?
    public init(dependencies: Dependencies) {
        self.authenticationViewModel = dependencies.authenticationViewModel
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
        self.userRepository = dependencies.userRepository
        super.init()
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SettingsViewCoordinator(haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
