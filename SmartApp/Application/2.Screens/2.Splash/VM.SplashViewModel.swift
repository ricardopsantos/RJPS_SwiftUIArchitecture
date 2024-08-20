//
//  SplashViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common

struct SplashModel: Equatable, Hashable, Sendable {
    let some: Bool
    public init(some: Bool = true) {
        self.some = some
    }
}

extension SplashViewModel {
    enum Actions {
        case didAppear
        case didDisappear
    }

    struct Dependencies {
        let model: SplashModel
        let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
        let onCompletion: () -> Void
    }
}

class SplashViewModel: BaseViewModel {
    // MARK: - Usage Attributes

    // MARK: - Auxiliar Attributes
    private var cancelBag = CancelBag()
    private var nonSecureAppPreferences: NonSecureAppPreferencesProtocol?
    public init(dependencies: Dependencies) {
        self.nonSecureAppPreferences = dependencies.nonSecureAppPreferences
    }

    // MARK: - Functions

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension RootViewModel {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SplashViewCoordinator(onCompletion: {})
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
