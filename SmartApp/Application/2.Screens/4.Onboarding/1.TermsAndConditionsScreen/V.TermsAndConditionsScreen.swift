//
//  TermsAndConditionsScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import DesignSystem

struct TermsAndConditionsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: TermsAndConditionsViewModel = TermsAndConditionsViewModel(
        sampleService: DependenciesManager.Services.sampleService
    )
    let onCompletion: (String) -> Void
    @State var isTermsSelected: Bool = false
    @State var isLoading: Bool = true
    @State var showError: Bool = false

    // MARK: - Views

    var body: some View {
        BaseView.with(
            sender: "\(Self.self)",
            appScreen: .termsAndConditions,
            navigationViewEmbed: false,
            scrollViewEmbed: false,
            ignoresSafeArea: false,
            background: .gradient,
            alertModel: viewModel.alertModel
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
                Header(text: "Terms&Conditions".localized)
                Text("DummyTermsAndConditions".localized)
                    .padding(.top, SizeNames.defaultMarginBig)
                termsView
                Spacer()
                TextButton(
                    onClick: { onNextPressed() },
                    text: "Next".localizedMissing,
                    background: canGoNext() ? .primaryColor : .gray
                )
            }
        }
        .padding()
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension TermsAndConditionsScreen {
    var termsView: some View {
        Button(action: {
            isTermsSelected.toggle()
        }) {
            HStack(spacing: SizeNames.defaultMarginSmall) {
                Image(systemName: isTermsSelected ? "checkmark.square" : "square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: SizeNames.defaultMargin)
                    .foregroundColor(.primaryColor)

                Text("ReadAndAcceptTerms&Conditions".localizedMissing)
                    .fontSemantic(.body)
                    .foregroundColor(.primaryColor)
            }
        }
        .padding(.top, SizeNames.defaultMarginBig)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//
// MARK: - Private
//
fileprivate extension TermsAndConditionsScreen {
    private func canGoNext() -> Bool {
        isTermsSelected
    }

    private func onNextPressed() {
        guard canGoNext() else {
            return
        }
        AnalyticsManager.shared.handleButtonClickEvent(
            buttonType: .primary,
            label: "Next",
            sender: "\(Self.self)"
        )
        onCompletion(#function)
    }
}

#Preview {
    TermsAndConditionsScreen(onCompletion: { _ in })
}
