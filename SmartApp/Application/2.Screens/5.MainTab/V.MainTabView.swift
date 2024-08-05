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
import DesignSystem

struct MainTabViewCoordinator: View {
    var body: some View {
        MainTabView(dependencies: .init(
            model: .init(selectedTab: .tab1)
        ))
    }
}

struct MainTabView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var tab1Router = RouterViewModel()
    @StateObject var tab2Router = RouterViewModel()
    @StateObject var tab3Router = RouterViewModel()
    @StateObject var tab4Router = RouterViewModel()
    @StateObject var viewModel: MainTabViewModel

    public init(dependencies: MainTabViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    var body: some View {
        content
    }

    var content: some View {
        TabView(selection: $viewModel.selectedTab) {
            NavigationStack(path: $tab1Router.navPath) {
                WeatherViewCoordinator()
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab1Router)
            }
            .tabItem { TabItemView(title: "Tab1", icon: "1.circle.fill") }
            .tag(Tab.tab1)
            
            NavigationStack(path: $tab2Router.navPath) {
                PopulationNationViewCoordinator()
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab2Router)
            }
            .tabItem { TabItemView(title: "Tab2", icon: "2.circle.fill") }
            .tag(Tab.tab2)

            NavigationStack(path: $tab3Router.navPath) {
                ___Template___ViewCoordinator()
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab3Router)
            }
            .tabItem { TabItemView(title: "Tab3", icon: "3.circle.fill") }
            .tag(Tab.tab3)

            NavigationStack(path: $tab4Router.navPath) {
                SettingsViewCoordinator()
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab4Router)
            }
            .tabItem { TabItemView(title: "Tab4", icon: "4.circle.fill") }
            .tag(Tab.tab4)
        }
        .accentColor(.primaryColor)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = ColorSemantic.backgroundTertiary.uiColor
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .weatherDetailsWith(model: let model):
            WeatherDetailsViewCoordinator(model: model)
                .environmentObject(configuration)
                .environmentObject(tab1Router)
        case .populationStates(year: let year, model: let model):
            PopulationStateViewCoordinator(year: year, model: model)
                .environmentObject(configuration)
                .environmentObject(tab2Router)
        default:
            EmptyView().onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

#Preview {
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
