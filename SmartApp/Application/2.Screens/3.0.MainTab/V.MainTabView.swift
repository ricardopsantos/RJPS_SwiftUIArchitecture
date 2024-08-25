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
    public init(dependencies: MainTabViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var tab1Router = RouterViewModel()
    @StateObject var tab2Router = RouterViewModel()
    @StateObject var tab3Router = RouterViewModel()
    @StateObject var tab4Router = RouterViewModel()
    @StateObject var tab5Router = RouterViewModel()

    // MARK: - Auxiliar Attributes
    // private let cancelBag: CancelBag = .init()

    // MARK: - Body & View
    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        TabView(selection: selectedTab()) {
            //
            // Tab 1 - Favorits
            //
            NavigationStack(path: $tab1Router.navPath) {
                FavoriteEventsViewCoordinator(haveNavigationStack: false)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab1Router)
            }
            .tabItem { TabItemView(title: Tab.tab1.title, icon: Tab.tab1.icon) }
            .tag(Tab.tab1)
            //
            // Tab 2 - Event as List
            //
            NavigationStack(path: $tab2Router.navPath) {
                EventsListViewCoordinator(haveNavigationStack: false)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab2Router)
            }
            .tabItem { TabItemView(title: Tab.tab2.title, icon: Tab.tab2.icon) }
            .tag(Tab.tab2)
            //
            // Tab 3 - Event as Calendar
            //
            NavigationStack(path: $tab3Router.navPath) {
                EventsCalendarViewCoordinator(haveNavigationStack: false)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab3Router)
            }
            .tabItem { TabItemView(title: Tab.tab3.title, icon: Tab.tab3.icon) }
            .tag(Tab.tab3)
            //
            // Tab 4 - Event as Map
            //
            NavigationStack(path: $tab4Router.navPath) {
                EventsMapViewCoordinator(haveNavigationStack: false)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab4Router)
            }
            .tabItem { TabItemView(title: Tab.tab4.title, icon: Tab.tab4.icon) }
            .tag(Tab.tab4)
            //
            // Tab 5
            //
            NavigationStack(path: $tab5Router.navPath) {
                SettingsViewCoordinator(haveNavigationStack: false)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .environmentObject(tab5Router)
            }
            .tabItem { TabItemView(title: Tab.tab5.title, icon: Tab.tab5.icon) }
            .tag(Tab.tab5)
        }
        .accentColor(.primaryColor)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = ColorSemantic.backgroundTertiary.uiColor
        }
        .onChange(of: tab1Router.navPath) { _ in
            DevTools.Log.debug("tab1Router.navPath changed", .view)
        }.onChange(of: tab2Router.navPath) { _ in
            DevTools.Log.debug("tab2Router.navPath changed", .view)
        }.onChange(of: tab3Router.navPath) { _ in
            DevTools.Log.debug("tab3Router.navPath changed", .view)
        }.onChange(of: tab4Router.navPath) { _ in
            DevTools.Log.debug("tab4Router.navPath changed", .view)
        }.onChange(of: tab5Router.navPath) { _ in
            DevTools.Log.debug("tab5Router.navPath changed", .view)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .eventLogDetails(model: let model):
            EventLogDetailsViewCoordinator(
                model: model,
                haveNavigationStack: false
            )
            .environmentObject(configuration)
            .environmentObject(tab1Router)
        case .eventDetails(model: let model):
            EventDetailsViewCoordinator(
                model: model,
                haveNavigationStack: false
            )
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
                case .tab5:
                    if !tab5Router.navigateToRoot() {
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
