//
//  TermsAndConditionsScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import DesignSystem
import DevTools
import Common

struct TermsAndConditionsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: TermsAndConditionsViewModel = TermsAndConditionsViewModel(
        sampleService: DependenciesManager.Services.sampleService
    )
    let onCompletion: (String) -> Void
    @State var isTermsSelected: Bool = false
    @State private var displayedText = ""
    private let termsAndConditions: String = "DummyTermsAndConditions".localized
    @State private var currentCharacterIndex: String.Index!

    // MARK: - Views

    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .termsAndConditions,
            navigationViewModel: .disabled,
            background: .defaultBackground,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil
        ) {
            content
        }.onAppear {
            viewModel.send(action: .didAppear)
            startTypingEffect()
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        ZStack {
            VStack {
                Header(text: "Terms&Conditions".localized)
                Text(displayedText)
                    .padding(.top, SizeNames.defaultMarginBig)
                termsView
                Spacer()
                TextButton(
                    onClick: { onNextPressed() },
                    text: "Next".localizedMissing,
                    background: canGoNext() ? .labelPrimary : .labelSecondary,
                    accessibility: .fwdButton
                )
            }
        }
        .padding()
    }

    func startTypingEffect() {
        Common_Utils.delay(1) {
            currentCharacterIndex = termsAndConditions.startIndex
            Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                displayedText.append(termsAndConditions[currentCharacterIndex])
                currentCharacterIndex = termsAndConditions.index(after: currentCharacterIndex)
                if currentCharacterIndex == termsAndConditions.endIndex {
                    timer.invalidate()
                }
            }
        }
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
        .accessibilityIdentifier(Accessibility.readTermsAndConditions.identifier)
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    TermsAndConditionsScreen(onCompletion: { _ in })
}
#endif
