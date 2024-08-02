//
//  ___Template___ViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 03/01/24.
//

import Foundation
import SwiftUI
//
import DevTools
import Common

//
// MARK: - Coordinator
//
struct ___Template___ViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var router = RouterViewModel()
    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $router.navPath) {
            buildScreen(.templateWith(model: .init(message: "!! Main !!")))
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $router.sheetLink, content: buildScreen)
                .fullScreenCover(item: $router.coverLink, content: buildScreen)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .templateWith(model: let model):
            let dependencies: ___Template___ViewModel.Dependencies = .init(
                model: model, onCompletion: { some in
                    Common.LogsManager.debug("Completed with \(some)")
                },
                sampleService: configuration.sampleService)
            ___Template___View(dependencies: dependencies)
        default:
            EmptyView().onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

//
// MARK: - View
//

struct ___Template___View: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: RouterViewModel
    @StateObject var viewModel: ___Template___ViewModel
    public init(dependencies: ___Template___ViewModel.Dependencies) {
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Auxiliar Attributes
    private var cancelBag: CancelBag = .init()

    // MARK: - Usage Attributes
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        BaseView.with(
            sender: "\(Self.self)",
            appScreen: .template,
            navigationViewEmbed: false,
            scrollViewEmbed: false,
            ignoresSafeArea: true,
            background: .gradient,
            displayRenderedView: true,
            alertModel: viewModel.alertModel) {
                content
            }.onAppear {
                viewModel.send(.didAppear)
            }.onDisappear {
                viewModel.send(.didDisappear)
            }
    }

    var content: some View {
        VStack {
            SwiftUIUtils.RenderedView("content")
            Text(viewModel.message)
            Button("Inc V1") {
                viewModel.send(.increment)
            }
            Divider()
            ___Template___Auxiliar.counterDisplayView(counterValue: $viewModel.counter) {
                viewModel.send(.increment)
            }
            ___Template___CounterDisplayView(counter: $viewModel.counter, onTap: {
                viewModel.send(.increment)
            })
            Divider()
            ___Template___AuxiliarAuthView()
            Divider()
            routingView
        }
    }
}

fileprivate extension ___Template___View {
    
    @ViewBuilder
    var routingView: some View {
        Button("Push") {
            viewModel.send(.routeToSceneX)
            router.navigate(
                to: AppScreen.templateWith(
                    model:
                    .init(message: "Push \(Date())", counter: 1)))
        }
        Button("Sheet") {
            viewModel.send(.routeToSceneX)
            router.sheetLink = .templateWith(
                model:
                .init(message: "Sheet \(Date())", counter: 1))
        }
        Button("Cover") {
            viewModel.send(.routeToSceneX)
            router.coverLink = .templateWith(
                model:
                .init(message: "Cover \(Date())", counter: 1))
        }
        Divider()
        Button("viewModel.send(.dismissThis)") {
            viewModel.send(.dismissThis)
            router.navigateBack()
        }.padding()
        Button("viewModel.send(.dismissAll)") {
            viewModel.send(.dismissAll)
            router.navigateToRoot()
        }.padding()
    }
}
//
// MARK: - View (Auxiliar)
//

struct ___Template___AuxiliarAuthView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    var body: some View {
        VStack {
            SwiftUIUtils.RenderedView("AuthView")
            Text(authenticationViewModel.isAuthenticated ? "Auth" : "Not Auth")
            Button("Toggle auth") {
                authenticationViewModel.isAuthenticated.toggle()
            }
        }
        .background(Color.red.opacity(0.1))
    }
}

struct ___Template___CounterDisplayView: View {
    var counter: Binding<Int>
    var onTap: () -> Void
    var body: some View {
        VStack {
            SwiftUIUtils.RenderedView("counterDisplayView")
            Text("___Template___Auxiliar.counterDisplayView")
            HStack {
                Button("Inc V.onTap", action: { onTap() })
                Button("Inc V.wrappedValue", action: { counter.wrappedValue += 1 })
            }
            Text(counter.wrappedValue.description)
        }
        .background(Color.green.opacity(0.1))
    }
}

public enum ___Template___Auxiliar {
    @ViewBuilder
    static func counterDisplayView(
        counterValue: Binding<Int>,
        onTap: @escaping () -> Void) -> some View {
        VStack {
            Text("___Template___Auxiliar.counterDisplayView")
            Button("Action 1", action: { onTap() })
            Button("Action 2", action: { counterValue.wrappedValue += 1 })
            Text(counterValue.wrappedValue.description)
        }
    }
}

#Preview {
    ___Template___ViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
