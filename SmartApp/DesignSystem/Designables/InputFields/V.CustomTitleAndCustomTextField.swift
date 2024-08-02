//
//  CustomTitleTextFieldView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//
import SwiftUI

public struct CustomTitleAndCustomTextField: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var inputText: String

    private let label: String
    private let placeholder: String
    private let isSecured: Bool
    private let accessibility: Accessibility

    public init(
        label: String,
        placeholder: String,
        inputText: Binding<String>,
        isSecured: Bool = false,
        accessibility: Accessibility
    ) {
        self._inputText = inputText
        self.label = label
        self.placeholder = placeholder
        self.accessibility = accessibility
        self.isSecured = isSecured
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontSemantic(.body)
                .foregroundColor(.labelPrimary)
            CustomTextField(
                inputText: $inputText,
                placeholder: placeholder,
                cornerRadius: SizeNames.cornerRadius,
                borderColor: .primaryColor,
                isSecured: isSecured,
                accessibility: accessibility
            )
        }
    }
}

#Preview {
    CustomTitleAndCustomTextField(
        label: "label",
        placeholder: "placeholder",
        inputText: .constant("inputText"),
        accessibility: .undefined
    )
}
