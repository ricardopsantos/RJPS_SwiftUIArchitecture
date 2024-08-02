//
//  Header.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common

public struct Header: View {
    @Environment(\.colorScheme) var colorScheme
    private let text: String
    private let hasBackButton: Bool
    private let hasCloseButton: Bool
    private let onBackOrCloseClick: () -> Void
    public init(
        text: String,
        hasBackButton: Bool = false,
        hasCloseButton: Bool = false,
        onBackOrCloseClick: @escaping () -> Void = {}
    ) {
        self.text = text
        self.hasBackButton = hasBackButton
        self.hasCloseButton = hasCloseButton
        self.onBackOrCloseClick = onBackOrCloseClick
    }

    public var body: some View {
        ZStack(alignment: hasBackButton ? .leading : .trailing) {
            if hasBackButton {
                Button(action: onBackOrCloseClick) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.primaryColor)
                }
            }
            Text(text)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fontSemantic(.headline)
                .foregroundColor(.primaryColor)
            if hasCloseButton {
                Button(action: onBackOrCloseClick) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primaryColor)
                }
            }
        }
    }
}

#Preview {
    VStack {
        Header(
            text: "Header",
            hasBackButton: false,
            hasCloseButton: false,
            onBackOrCloseClick: {}
        )
        SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            .backgroundColorSemantic(.allCool)
        Header(
            text: "Header hasBackButton",
            hasBackButton: true,
            hasCloseButton: false,
            onBackOrCloseClick: {}
        )
        SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            .backgroundColorSemantic(.allCool)
        Header(
            text: "Header hasCloseButton",
            hasBackButton: false,
            hasCloseButton: true,
            onBackOrCloseClick: {}
        )
        Spacer()
    }
    .padding()
    .background(ColorSemantic.backgroundPrimary.color)
}
