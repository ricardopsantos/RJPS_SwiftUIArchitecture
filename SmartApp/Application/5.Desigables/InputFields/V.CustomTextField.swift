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
    var isSecured: Bool = false

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
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    TextField("", text: $inputText)
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
            borderColor: Color.primary,
            isSecured: false
        )
        CustomTextField(
            inputText: .constant("inputText"),
            placeholder: "placeholder",
            cornerRadius: SizeNames.cornerRadius,
            borderColor: Color.primary,
            isSecured: true
        )
    }
}
