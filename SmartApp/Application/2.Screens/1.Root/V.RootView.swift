//
//  RootView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common
import DevTools

//
// MARK: - Coordinator
//
struct RootViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.root)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    /// Navigation Links
    @ViewBuilder func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .root:
            RootView(dependencies: .init(model: .init(appLoaded: false)))
        default:
            EmptyView().opacity(0).onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

//
// MARK: - View
//
struct RootView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: RootViewModel
    public init(dependencies: RootViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage Attributes
    @State private var root: AppScreen = .splash {
        didSet {
            DevTools.Log.debug(
                .valueChanged(
                    "\(Self.self)",
                    "root",
                    "\(root)"
                ),
                .business
            )
        }
    }

    // MARK: - Body & View
    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        if Common_Utils.onSimulator {
            // swiftlint:disable redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable redundant_discardable_let
        }
        buildScreen(root)
            .onChange(of: viewModel.appLoaded) { _ in updateRoot() }
    }

    /// Navigation Links
    @ViewBuilder private func buildScreen(_ appScreen: AppScreen) -> some View {
        switch appScreen {
        case .splash:
            SplashView()
                .onAppear {
                    viewModel.send(action: .start)
                }
        case .populationNation:
            PopulationNationViewCoordinator()
        default:
            Text("Not predicted \(root)")
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension RootView {}

//
// MARK: - Private
//
fileprivate extension RootView {
    func updateRoot() {
        if viewModel.appLoaded {
            root = .populationNation
        } else {
            root = .splash
        }
    }
}

#Preview {
    RootViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
