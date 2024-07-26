//
//  CustomTitleTextFieldView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//
import SwiftUI
import DesignSystem

struct CustomTitleAndCustomTextField: View {
    @Environment(\.colorScheme) var colorScheme
    var label: String
    var placeholder: String
    var isSecured: Bool = false
    @Binding var inputText: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontSemantic(.body)
                .foregroundColor(.labelPrimary)
            CustomTextField(
                inputText: $inputText,
                placeholder: placeholder,
                cornerRadius: SizeNames.cornerRadius,
                borderColor: .primaryColor,
                isSecured: isSecured
            )
        }
    }
}

#Preview {
    CustomTitleAndCustomTextField(
        label: "Title",
        placeholder: "placeholder",
        inputText: .constant("inputText")
    )
}
