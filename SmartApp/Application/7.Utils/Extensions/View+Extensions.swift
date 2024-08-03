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
    func customBackButton(action: @escaping () -> Void, title: String = "") -> some View {
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
            }
    }
}
