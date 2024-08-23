//
//  DesignSystem+Extensions.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 23/08/2024.
//

import Foundation
import SwiftUI
//
import Common

extension Text {
    func applyStyle(_ style: TextStyleTuple, _ theme: Common.InterfaceStyle? = nil) -> some View {
        if let theme = theme, let color: Color = style.color?.color(theme) {
            return textColor(color)
                .fontSemantic(style.font)
        } else {
            return textColor(style.color?.color)
                .fontSemantic(style.font)
        }
    }
}
