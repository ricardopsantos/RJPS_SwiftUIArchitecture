//
//  MainTabViewModel.swift
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
    }

    struct Dependencies {
        let model: MainTabModel
    }
}

class MainTabViewModel: BaseViewModel {
    // MARK: - Usage Attributes
    @Published var selectedTab: Tab = .tab1

    // MARK: - Auxiliar Attributes
    public init(dependencies: Dependencies) {
        self.selectedTab = dependencies.model.selectedTab
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
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
