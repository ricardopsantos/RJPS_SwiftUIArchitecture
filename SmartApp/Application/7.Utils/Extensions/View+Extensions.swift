//
//  View+Extensions.swift
//  Core
//
//  Created by Ricardo Santos on 02/08/2024.
//

import SwiftUI
//
import DesignSystem

public extension View {
    func customBackButtonV1(
        action: @escaping () -> Void,
        title: String = ""
    ) -> some View {
        navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        action()
                    } label: {
                        Image(.back)
                            .resizable()
                            .scaledToFit()
                            .frame(width: SizeNames.defaultMargin * 1.5)
                            .tint(ColorSemantic.primary.color)
                    }.accessibilityIdentifier(Accessibility.backButton.identifier)
                }
                if !title.isEmpty {
                    ToolbarItem(placement: .principal) {
                        Header(text: title)
                    }
                }
            }.background(Color.red)
    }

    func customBackButtonV2(
        action: @escaping () -> Void,
        title: String
    ) -> some View {
        navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Header(text: title, hasBackButton: true, onBackOrCloseClick: action)
                }
            }
    }
}
