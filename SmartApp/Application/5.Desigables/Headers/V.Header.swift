//
//  Header.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import DesignSystem

struct Header: View {
    @Environment(\.colorScheme) var colorScheme
    var text: String
    var hasBackButton: Bool = false
    var hasCloseButton: Bool = false
    var onBackOrCloseClick: () -> Void = {}

    var body: some View {
        ZStack(alignment: hasBackButton ? .leading : .trailing) {
            if hasBackButton {
                Button(action: onBackOrCloseClick) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.primaryColor)
                }
            }
            Text(text)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(FontSemantic.title2.font)
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
    Header(
        text: "Heading",

        hasBackButton: false,
        hasCloseButton: false,
        onBackOrCloseClick: {}
    )
}
