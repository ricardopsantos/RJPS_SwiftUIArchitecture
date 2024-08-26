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
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    let haveNavigationStack: Bool
    let model: ___Template___Model
    // MARK: - Body & View
    var body: some View {
        if haveNavigationStack {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.templateWith(model: model))
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .sheet(item: $coordinator.sheetLink, content: buildScreen)
                    .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            }
        } else {
            buildScreen(.templateWith(model: model))
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .templateWith(model: let model):
            let dependencies: ___Template___ViewModel.Dependencies = .init(
                model: model, onCompletion: { _ in

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
    @StateObject var viewModel: ___Template___ViewModel
    public init(dependencies: ___Template___ViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let cancelBag: CancelBag = .init()

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .templateWith(model: .init()),
            navigationViewModel: .disabled,
            ignoresSafeArea: false,
            background: .defaultBackground,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil) {
                content
            }.onAppear {
                viewModel.send(.didAppear)
            }.onDisappear {
                viewModel.send(.didDisappear)
            }
    }

    var content: some View {
        VStack {
            SwiftUIUtils.RenderedView("\(Self.self).\(#function)")
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
            Button("Display error") {
                viewModel.send(.displayRandomError)
            }
            Divider()
            routingView
        }
    }
}

fileprivate extension ___Template___View {
    @ViewBuilder
    var routingView: some View {
        EmptyView()
    }
}

//
// MARK: - View (Auxiliar)
//

struct ___Template___AuxiliarAuthView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    var body: some View {
        VStack {
            SwiftUIUtils.RenderedView("\(Self.self).\(#function)")
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
            SwiftUIUtils.RenderedView("\(Self.self).\(#function)")
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    ___Template___ViewCoordinator(haveNavigationStack: false, model: .init(message: "Hi"))
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
