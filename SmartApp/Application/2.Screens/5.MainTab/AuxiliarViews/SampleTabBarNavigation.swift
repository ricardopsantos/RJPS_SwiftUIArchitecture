//
//  Created by Ricardo Santos on 05/08/2024.
//

import Foundation
import SwiftUI

struct SampleTabBarNavigation {
    enum SampleScreen: Hashable, Identifiable {
        case sampleTextView(text: String)
        var id: String {
            String(describing: self)
        }
    }

    struct TabBar: View {
        @StateObject var tab1Router = RouterViewModel()
        @StateObject var tab2Router = RouterViewModel()

        var body: some View {
            TabView {
                NavigationStack(path: $tab1Router.navPath) {
                    Tab1View()
                        .environmentObject(tab1Router)
                        .navigationDestination(for: SampleScreen.self, destination: buildSampleScreen)
                }
                .tabItem {
                    Label("Tab 1", systemImage: "1.circle")
                }

                NavigationStack(path: $tab2Router.navPath) {
                    Tab2View()
                        .environmentObject(tab2Router)
                        .navigationDestination(for: SampleScreen.self, destination: buildSampleScreen)
                }
                .tabItem {
                    Label("Tab 2", systemImage: "2.circle")
                }

                NavigationStack {
                    Tab3View()
                }
                .tabItem {
                    Label("Tab 3", systemImage: "3.circle")
                }
            }
        }

        @ViewBuilder private func buildSampleScreen(_ appScreen: SampleScreen) -> some View {
            switch appScreen {
            case .sampleTextView(text: let text):
                DetailView(item: text)
            }
        }
    }

    struct Tab1View: View {
        @EnvironmentObject var tabRouter: RouterViewModel
        private let items = (1...5).map { "\(Self.self) Item \($0)" }
        var body: some View {
            List(items, id: \.self) { item in
                Button(action: {
                    tabRouter.navigate(to: SampleScreen.sampleTextView(text: item))
                }) {
                    Text(item)
                }
            }
        }
    }

    struct Tab2View: View {
        @EnvironmentObject var tabRouter: RouterViewModel
        private let items = (1...5).map { "\(Self.self) Item \($0)" }
        var body: some View {
            List(items, id: \.self) { item in
                Button(action: {
                    tabRouter.navigate(to: SampleScreen.sampleTextView(text: item))
                }) {
                    Text(item)
                }
            }
        }
    }

    struct Tab3View: View {
        var body: some View {
            Text("Tab 3")
        }
    }

    struct DetailView: View {
        let item: String

        var body: some View {
            Text(item)
        }
    }
}

#Preview {
    SampleTabBarNavigation.TabBar()
}
