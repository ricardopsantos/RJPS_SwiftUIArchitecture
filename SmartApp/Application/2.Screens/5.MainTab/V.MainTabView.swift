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

struct MainTabView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: MainTabViewModel

    // MARK: - Usage Attributes
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var tab1Router = RouterViewModel()
    @StateObject var tab2Router = RouterViewModel()
    @StateObject var tab3Router = RouterViewModel()
    @StateObject var tab4Router = RouterViewModel()

    public init(dependencies: MainTabViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    var body: some View {
        content
    }

    var content: some View {
        TabView(selection: selectedTab()) {
            NavigationStack(path: $tab1Router.navPath) {
                WeatherViewCoordinator()
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab1Router)
            }
            .tabItem { TabItemView(title: Tab.tab1.title, icon: Tab.tab1.icone) }
            .tag(Tab.tab1)

            NavigationStack(path: $tab2Router.navPath) {
                PopulationNationViewCoordinator()
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab2Router)
            }
            .tabItem { TabItemView(title: Tab.tab2.title, icon: Tab.tab2.icone) }
            .tag(Tab.tab2)

            NavigationStack(path: $tab3Router.navPath) {
                ___Template___ViewCoordinator()
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab3Router)
            }
            .tabItem { TabItemView(title: Tab.tab3.title, icon: Tab.tab3.icone) }
            .tag(Tab.tab3)

            NavigationStack(path: $tab4Router.navPath) {
                SettingsViewCoordinator()
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab4Router)
            }
            .tabItem { TabItemView(title: Tab.tab4.title, icon: Tab.tab4.icone) }
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

extension MainTabView {
    // https://betterprogramming.pub/swiftui-navigation-stack-and-ideal-tab-view-behaviour-e514cc41a029
    private func selectedTab() -> Binding<Tab> {
        Binding {
            viewModel.selectedTab
        } set: { tappedTab in
            if tappedTab == viewModel.selectedTab {
                DevTools.Log.debug("Double Tap", .view)
                switch viewModel.selectedTab {
                case .tab1:
                    if !tab1Router.navigateToRoot() {
                        // Scroll up?
                        DevTools.Log.debug("Should scroll up?", .view)
                    }
                case .tab2:
                    if !tab2Router.navigateToRoot() {
                        // Scroll up?
                        DevTools.Log.debug("Should scroll up?", .view)
                    }
                case .tab3:
                    if !tab3Router.navigateToRoot() {
                        // Scroll up?
                        DevTools.Log.debug("Should scroll up?", .view)
                    }
                case .tab4:
                    if !tab4Router.navigateToRoot() {
                        // Scroll up?
                        DevTools.Log.debug("Should scroll up?", .view)
                    }
                }
            } else {
                viewModel.selectedTab = tappedTab
            }
        }
    }
}

#Preview {
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
