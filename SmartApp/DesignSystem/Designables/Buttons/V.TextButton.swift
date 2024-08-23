//  TextButton.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI

public struct TextButton: View {
    @Environment(\.colorScheme) var colorScheme

    public enum Style: String, CaseIterable, Equatable, Hashable {
        case primary, secondary, textOnly
    }

    // MARK: - Attributes
    private let onClick: () -> Void
    private let text: String
    private let alignment: Alignment
    private let style: Style
    private let background: Color
    private let enabled: Bool
    private let accessibility: Accessibility

    public init(
        onClick: @escaping () -> Void,
        text: String,
        alignment: Alignment = .center,
        style: Style = .primary,
        background: Color = .primaryColor,
        enabled: Bool = true,
        accessibility: Accessibility
    ) {
        self.onClick = onClick
        self.text = text
        self.alignment = alignment
        self.style = style
        self.background = background
        self.enabled = enabled
        self.accessibility = accessibility
    }

    // MARK: - Views
    public var body: some View {
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
                .frame(maxWidth: .infinity, alignment: alignment)
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
        .accessibilityIdentifier(accessibility.identifier)
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack {
        ForEach(TextButton.Style.allCases, id: \.self) { style in
            HStack {
                // Default
                TextButton(
                    onClick: {},
                    text: "\(style)",
                    alignment: .center,
                    style: style,
                    background: .primaryColor,
                    enabled: true,
                    accessibility: .undefined
                )
                TextButton(
                    onClick: {},
                    text: "\(style)",
                    alignment: .center,
                    style: style,
                    background: .primaryColor,
                    enabled: false,
                    accessibility: .undefined
                )
                // Destructive
                TextButton(
                    onClick: {},
                    text: "\(style)",
                    alignment: .center,
                    style: style,
                    background: .dangerColor,
                    enabled: true,
                    accessibility: .undefined
                )
            }
        }
    }
    .padding()
}
#endif
