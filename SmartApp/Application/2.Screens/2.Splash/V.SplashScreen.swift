//
//  SplashScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common
import DesignSystem
import DevTools

//
// MARK: - Coordinator
//
struct SplashViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage Attributes
    let onCompletion: () -> Void

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $coordinator.navPath) {
            buildScreen(.splash)
                .navigationDestination(for: AppScreen.self, destination: buildScreen)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .splash:
            let dependencies: SplashViewModel.Dependencies = .init(
                model: .init(),
                nonSecureAppPreferences: configuration.nonSecureAppPreferences,
                onCompletion: onCompletion
            )
            SplashView(dependencies: dependencies)
        default:
            EmptyView().onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
        }
    }
}

struct SplashView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: SplashViewModel
    public init(dependencies: SplashViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onCompletion = dependencies.onCompletion
    }

    // MARK: - Usage Attributes
    @Environment(\.dismiss) var dismiss
    @State private var logoOpacity: Double = 0

    // MARK: - Auxiliar Attributes
    let onCompletion: () -> Void

    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .splash,
            navigationViewModel: .disabled,
            ignoresSafeArea: true,
            background: .uiColor(UIColor.colorFromRGBString("239,239,235")),
            loadingModel: nil,
            alertModel: nil,
            networkStatus: nil
        ) {
            content
        }
        .onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
        .onAppear {
            let animationDuration = Common.Constants.defaultAnimationsTime * 2
            let animationDelay = Common.Constants.defaultAnimationsTime
            withAnimation(.linear(duration: animationDuration).delay(animationDelay)) {
                logoOpacity = 1
            }
            let splashTimeToLive = animationDuration + animationDelay + Common.Constants.defaultAnimationsTime
            Common_Utils.delay(splashTimeToLive) {
                onCompletion()
            }
        }
    }

    var content: some View {
        VStack {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth * 0.5)
                .opacity(logoOpacity)
        }
        .padding()
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension SplashView {}

//
// MARK: - Private
//
fileprivate extension SplashView {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SplashViewCoordinator(onCompletion: {})
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
