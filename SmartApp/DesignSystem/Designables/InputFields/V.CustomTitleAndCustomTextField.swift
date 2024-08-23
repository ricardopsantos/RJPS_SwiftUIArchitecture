//
//  CustomTitleTextFieldView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//
import SwiftUI
//
import DevTools

public struct CustomTitleAndCustomTextFieldV2: View {
    @State private var inputText: String = ""

    private let label: String
    private let placeholder: String
    private let isSecured: Bool
    private let accessibility: Accessibility
    private let onTextChange: (String) -> Void

    public init(
        label: String,
        placeholder: String,
        isSecured: Bool = false,
        accessibility: Accessibility,
        onTextChange: @escaping (String) -> Void
    ) {
        self.label = label
        self.placeholder = placeholder
        self.isSecured = isSecured
        self.accessibility = accessibility
        self.onTextChange = onTextChange
    }

    public var body: some View {
        CustomTitleAndCustomTextFieldV1(
            label: label,
            placeholder: placeholder,
            inputText: $inputText,
            isSecured: isSecured,
            accessibility: accessibility
        )
        .onChange(of: inputText) { newValue in
            onTextChange(newValue)
        }
    }
}


public struct CustomTitleAndCustomTextFieldV1: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var inputText: String

    private let label: String // Title value
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

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack {
        CustomTitleAndCustomTextFieldV1(
            label: "label",
            placeholder: "placeholder",
            inputText: .constant("inputText"),
            accessibility: .undefined
        )
        CustomTitleAndCustomTextFieldV2(label: "label",
                                        placeholder: "placeholder",
                                        accessibility: .undefined) { newText in
            DevTools.Log.debug(newText, .generic)
        }
    }
}
#endif
