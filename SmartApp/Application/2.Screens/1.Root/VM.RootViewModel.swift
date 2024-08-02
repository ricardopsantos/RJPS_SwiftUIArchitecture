//
//  RootViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

struct RootModel: Equatable, Hashable {
    let isAppStartCompleted: Bool
    init(isAppStartCompleted: Bool = false) {
        self.isAppStartCompleted = isAppStartCompleted
    }
}

extension RootViewModel {
    enum Actions {
        case start
    }

    struct Dependencies {
        let model: RootModel
        //let nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    }
}

@MainActor
class RootViewModel: ObservableObject {
    // MARK: - Usage Attributes
    @Published private(set) var alertModel: Model.AlertModel?
    @Published private(set) var isAppStartCompleted: Bool = false
    @Published private(set) var isUserDetailsFilled: Bool = false
    @Published private(set) var isTermsAndConditionsAccepted: Bool = false
    @Published private(set) var isOnboardingCompleted: Bool = false
    @Published private(set) var preferencesChanged: Date = .now

    // MARK: - Auxiliar Attributes
    private var cancelBag = CancelBag()
    public init(dependencies: Dependencies) {
        self.isAppStartCompleted = dependencies.model.isAppStartCompleted
    }

    // MARK: - Functions

    func send(action: Actions) {
        switch action {
        case .start:
            guard !isAppStartCompleted else { return }
            // All starting set up will be done here
            // testing load time 0.3 seconds
            Common_Utils.delay(Common.Constants.defaultAnimationsTime) { [weak self] in
                self?.isAppStartCompleted = true
            }
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension RootViewModel {}

#Preview {
    RootViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
