//
//  MainTabCoordinator.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
//
import Domain
import Common
import Core
import DevTools

struct MainTabViewCoordinator: View, ViewCoordinatorProtocol {
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()

    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.mainApp)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    /// Navigation Links
    @ViewBuilder func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .mainApp:
            MainTabView(dependencies: .init(
                model: .init(selectedTab: .tab1),
                sampleService: configuration.sampleService))
        default:
            EmptyView().onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

struct MainTabView: View, ViewProtocol {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: MainTabViewModel
    public init(dependencies: MainTabViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    var body: some View {
        if Common_Utils.onSimulator {
            // swiftlint:disable redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable redundant_discardable_let
        }
        content
    }

    var content: some View {
        TabView(selection: $viewModel.selectedTab, content: {
            WeatherViewCoordinator()
                .tabItem { TabItemView(title: "Tab1", icon: "1.circle.fill") }
                .tag(Tab.tab1)
            PopulationNationViewCoordinator()
                .tabItem { TabItemView(title: "Tab2", icon: "2.circle.fill") }
                .tag(Tab.tab2)
            ___Template___ViewCoordinator()
                .tabItem { TabItemView(title: "Tab3", icon: "3.circle.fill") }
                .tag(Tab.tab3)
            SettingsViewCoordinator()
                .tabItem { TabItemView(title: "Tab4", icon: "4.circle.fill") }
                .tag(Tab.tab4)
        })
        .accentColor(.primaryColor)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor(.backgroundTertiary)
        }
    }
}

#Preview {
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
