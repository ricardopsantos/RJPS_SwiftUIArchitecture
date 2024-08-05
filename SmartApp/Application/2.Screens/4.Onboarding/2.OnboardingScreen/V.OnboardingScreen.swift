//
//  OnboardingScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import DesignSystem

struct OnboardingScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: OnboardingViewModel = OnboardingViewModel(
        sampleService: DependenciesManager.Services.sampleService
    )
    let images: [Image] = [
        Image(.onboarding1),
        Image(.onboarding2)
    ]
    let onCompletion: (String) -> Void
    let onBackPressed: () -> Void

    @State private var selectedTab = 0

    var buttonText: String {
        selectedTab == (images.count - 1) ? "GetStarted".localizedMissing : "Next".localizedMissing
    }

    // MARK: - Views

    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .onboarding,
            navigationViewModel: .disabled,
            background: .default,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil
        ) {
            content
        }.onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        ZStack {
            VStack {
                Header(
                    text: "Onboarding".localizedMissing,
                    hasBackButton: true,
                    onBackOrCloseClick: {
                        AnalyticsManager.shared.handleButtonClickEvent(
                            buttonType: .back,
                            label: "Back",
                            sender: "\(Self.self)"
                        )
                        onBackPressed() }
                )

                pageView

                TextButton(onClick: onNextButtonPressed, text: buttonText, accessibility: .fwdButton)
            }
            .padding()
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension OnboardingScreen {
    var pageView: some View {
        TabView(selection: $selectedTab) {
            ForEach(0..<images.count, id: \.self) { index in
                images[index]
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

//
// MARK: - Private
//
fileprivate extension OnboardingScreen {
    private func onNextButtonPressed() {
        AnalyticsManager.shared.handleButtonClickEvent(
            buttonType: .primary,
            label: selectedTab == (images.count - 1) ? "GetStarted" : "Next",
            sender: "\(Self.self)"
        )
        if selectedTab < (images.count - 1) {
            withAnimation {
                selectedTab += 1
            }
        } else {
            onCompletion(#function)
        }
    }
}

#Preview {
    OnboardingScreen(onCompletion: { _ in }, onBackPressed: {})
}
