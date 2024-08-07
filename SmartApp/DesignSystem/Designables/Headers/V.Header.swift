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
        ZStack {
            if hasBackButton {
                HStack {
                    Button(action: onBackOrCloseClick) {
                        AppImages.arrowBackward.image
                            .resizable()
                            .scaledToFit()
                            .frame(SizeNames.defaultMarginSmall)
                            .tint(ColorSemantic.primary.color)
                        Spacer()
                    }
                }
            }
            Text(text)
                .frame(
                    maxWidth: screenWidth - 4 * SizeNames.defaultMargin,
                    alignment: .center
                )
                .font(FontSemantic.headline.font)
                .foregroundColor(.primaryColor)
            if hasCloseButton {
                HStack {
                    Spacer()
                    Button(action: onBackOrCloseClick) {
                        AppImages.close.image
                            .resizable()
                            .scaledToFit()
                            .frame(SizeNames.defaultMarginSmall)
                            .tint(ColorSemantic.primary.color)
                    }
                }
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
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
#endif
