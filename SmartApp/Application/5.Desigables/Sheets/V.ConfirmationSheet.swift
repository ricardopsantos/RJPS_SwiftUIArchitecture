//
//  ConfirmationSheet.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
import DesignSystem

struct ConfirmationSheetV2: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isOpen: Bool
    private let title: String
    private let subTitle: String
    private let leftText: String
    private let rightText: String
    private var confirmationAction: () -> Void
    public init(
        isOpen: Binding<Bool>,
        title: String = "Alert".localizedMissing,
        subTitle: String = "Are you really really sure that you want to go ahead with this action?",
        leftText: String = "No",
        rightText: String = "Yes",
        confirmationAction: @escaping () -> Void
    ) {
        self._isOpen = isOpen
        self.title = title
        self.subTitle = subTitle
        self.leftText = leftText
        self.rightText = rightText
        self.confirmationAction = confirmationAction
    }

    var body: some View {
        VStack {
            Spacer()
            ConfirmationSheetV1(
                isOpen: $isOpen,
                title: title,
                subTitle: subTitle,
                leftText: leftText,
                rightText: rightText,
                confirmationAction: confirmationAction
            )
            .backgroundColorSemantic(.backgroundGradient)
            .cornerRadius2(SizeNames.cornerRadius)
            .padding(SizeNames.defaultMargin)
            Spacer()
        }
        .background(
            // Transparent overlay to capture taps
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // Do nothing to disable tap outside
                }
        )
        .presentationDetents([.fraction(0.25), .medium, .large])
    }
}

struct ConfirmationSheetV1: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isOpen: Bool
    private var confirmationAction: () -> Void
    private let title: String
    private let subTitle: String
    private let leftText: String
    private let rightText: String
    init(
        isOpen: Binding<Bool>,
        title: String,
        subTitle: String,
        leftText: String,
        rightText: String,
        confirmationAction: @escaping () -> Void
    ) {
        self._isOpen = isOpen
        self.title = title
        self.subTitle = subTitle
        self.leftText = leftText
        self.rightText = rightText
        self.confirmationAction = confirmationAction
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .fontSemantic(.headline)
                .paddingBottom(SizeNames.defaultMargin)
            Text(subTitle)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .fontSemantic(.body)
                .paddingBottom(SizeNames.defaultMargin)
            HStack(spacing: SizeNames.defaultMargin) {
                TextButton(
                    onClick: {
                        isOpen.toggle()
                    },
                    text: leftText,
                    style: .secondary,
                    background: .primaryColor, 
                    accessibility: .confirmButton
                )
                TextButton(
                    onClick: {
                        confirmationAction()
                        isOpen.toggle()
                    },
                    text: rightText,
                    style: .primary,
                    background: .primaryColor,
                    accessibility: .cancelButton
                )
            }
        }.padding(SizeNames.defaultMargin)
    }
}

#Preview {
    ConfirmationSheetV1(
        isOpen: .constant(true),
        title: "title",
        subTitle: "subTitle",
        leftText: "leftText",
        rightText: "rightText", confirmationAction: {}
    )
}
