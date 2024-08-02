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
    let appLoaded: Bool
    init(appLoaded: Bool = false) {
        self.appLoaded = appLoaded
    }
}

extension RootViewModel {
    enum Actions {
        case start
    }

    struct Dependencies {
        let model: RootModel
    }
}

@MainActor
class RootViewModel: ObservableObject {
    // MARK: - Usage Attributes
    @Published private(set) var alertModel: Model.AlertModel?
    @Published private(set) var appLoaded: Bool = false

    // MARK: - Auxiliar Attributes
    private var cancelBag = CancelBag()
    public init(dependencies: Dependencies) {
        self.appLoaded = dependencies.model.appLoaded
    }

    // MARK: - Functions

    func send(action: Actions) {
        switch action {
        case .start:
            guard !appLoaded else { return }
            appLoaded = true
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
