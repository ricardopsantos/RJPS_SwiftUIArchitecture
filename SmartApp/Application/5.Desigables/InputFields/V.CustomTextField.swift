//
//  CustomTextField.swift
//  SmartApp
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
import DesignSystem

struct CustomTextField: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var inputText: String
    var placeholder: String
    var cornerRadius: CGFloat
    var borderColor: Color
    let isSecured: Bool
    let accessibility: AppConstants.Accessibility

    public init(
        inputText: Binding<String>,
        placeholder: String,
        cornerRadius: CGFloat,
        borderColor: Color,
        isSecured: Bool = false,
        accessibility: AppConstants.Accessibility
    ) {
        self._inputText = inputText
        self.isSecured = isSecured
        self.placeholder = placeholder
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.accessibility = accessibility
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if inputText.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, SizeNames.defaultMarginSmall)
            }
            Group {
                if isSecured {
                    SecureField("", text: $inputText)
                        .accessibilityIdentifier(accessibility.identifier)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    TextField("", text: $inputText)
                        .accessibilityIdentifier(accessibility.identifier)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .padding(.horizontal, SizeNames.defaultMarginSmall)
            .padding(.vertical, SizeNames.defaultMarginSmall)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack {
        CustomTextField(
            inputText: .constant("inputText"),
            placeholder: "placeholder",
            cornerRadius: SizeNames.cornerRadius,
            borderColor: ColorSemantic.allCool.color,
            isSecured: false,
            accessibility: .undefined
        )
        CustomTextField(
            inputText: .constant("inputText"),
            placeholder: "placeholder",
            cornerRadius: SizeNames.cornerRadius,
            borderColor: Color.primary,
            isSecured: true,
            accessibility: .undefined
        )
    }
}
