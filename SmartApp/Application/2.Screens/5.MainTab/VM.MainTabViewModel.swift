//
//  MainTabViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import Foundation
import SwiftUI
//
import Common
import Core

struct MainTabModel: Equatable, Hashable {
    let selectedTab: Tab

    init(selectedTab: Tab) {
        self.selectedTab = selectedTab
    }
}

//
// MARK: - ViewModel Builder
//

extension MainTabViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case doSomething
    }

    struct Dependencies {
        let model: MainTabModel
        let sampleService: SampleServiceProtocol
    }
}

@MainActor
class MainTabViewModel: ObservableObject {
    @Published var selectedTab: Tab = .tab1
    @Published var alertModel: Model.AlertModel?
    private let sampleService: SampleServiceProtocol?
    public init(dependencies: Dependencies) {
        self.sampleService = dependencies.sampleService
        self.selectedTab = dependencies.model.selectedTab
    }

    func send(action: Actions) {
        switch action {
        case .didAppear: ()
        case .didDisappear: ()
        case .doSomething: () // Do something
        }
    }
}

#Preview {
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
