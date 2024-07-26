//  TextButton.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import DesignSystem

struct TextButton: View {
    @Environment(\.colorScheme) var colorScheme

    enum Style: CaseIterable {
        case primary, secondary, textOnly
    }

    // MARK: - Attributes
    var onClick: () -> Void
    var text: String
    var style: Style = .primary
    var background: Color = .primaryColor
    var enabled: Bool = true
    // MARK: - Views
    var body: some View {
        Button(action: onClick) {
            Text(text)
                .fontSemantic(.body)
                .doIf(enabled, transform: {
                    $0.foregroundColorSemantic(.labelPrimary)
                        .foregroundColor(style == .primary ? .labelPrimary : .labelSecondary)
                })
                .doIf(!enabled, transform: {
                    $0.foregroundColorSemantic(.labelSecondary)
                        .foregroundColor(style == .primary ? .labelPrimary : .labelSecondary)
                })
                .frame(maxWidth: .infinity)
                .padding(SizeNames.defaultMarginSmall)
                .background(backgroundColor)
                .cornerRadius(SizeNames.defaultButtonPrimaryHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: SizeNames.defaultButtonPrimaryHeight)
                        .inset(by: 0.75)
                        .stroke(stroke, lineWidth: 1.5)
                )
                .contentShape(Rectangle())
                .userInteractionEnabled(enabled)
        }
        .buttonStyle(.plain)
        .shadow(radius: SizeNames.defaultMarginSmall)
    }
}

extension TextButton {
    var stroke: Color {
        let color = (style == .secondary ? background : .clear)
        return enabled ? color : color.opacity(0.3)
    }

    var backgroundColor: Color {
        switch style {
        case .primary: enabled ? background : background.opacity(0.3)
        case .textOnly, .secondary: Color.clear
        }
    }
}

#Preview {
    VStack {
        ForEach(TextButton.Style.allCases, id: \.self) { style in
            HStack {
                TextButton(
                    onClick: {},
                    text: "\(style)",
                    style: style,
                    background: .primaryColor,
                    enabled: true
                )
                TextButton(
                    onClick: {},
                    text: "\(style)",
                    style: style,
                    background: .primaryColor,
                    enabled: false
                )
            }
        }
    }
    .padding()
}
