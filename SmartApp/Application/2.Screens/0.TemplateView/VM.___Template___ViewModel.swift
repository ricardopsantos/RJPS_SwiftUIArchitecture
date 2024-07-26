//
//  ___Template___ViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 03/01/24.
//

import Foundation
import SwiftUI
//
import Common
import Core

//
// MARK: - Model
//

struct ___Template___Model: Equatable, Hashable {
    let message: String
    let counter: Int

    init(message: String = "", counter: Int = 0) {
        self.message = message
        self.counter = counter
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension ___Template___ViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case dismissThis
        case increment
        case dismissAll
        case routeToSceneX
    }

    struct Dependencies {
        let model: ___Template___Model
        let onCompletion: (String) -> Void
        let sampleService: SampleServiceProtocol
    }
}

//
// MARK: - ViewModel
//
@MainActor
class ___Template___ViewModel: ObservableObject {
    @Published private(set) var message: String = ""
    @Published var counter: Int = 0
    @Published private(set) var alertModel: Model.AlertModel?
    private let sampleService: SampleServiceProtocol?
    public init(dependencies: Dependencies) {
        self.sampleService = dependencies.sampleService
        self.message = dependencies.model.message
        self.counter = dependencies.model.counter
    }

    func send(_ action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .increment: ()
            counter += 1
            message = "Counter: \(counter)"
        case .routeToSceneX: ()
        case .dismissThis: ()
        case .dismissAll: ()
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension ___Template___ViewModel {}

//
// MARK: - Preview
//

#Preview {
    ___Template___ViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
