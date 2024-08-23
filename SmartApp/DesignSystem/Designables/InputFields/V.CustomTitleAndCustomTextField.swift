//
//  CustomTitleTextFieldView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//
import SwiftUI
//
import DevTools
import Common

public struct CustomTitleAndCustomTextFieldWithState: View {
    @State private var inputText: String = ""

    private let title: String
    private let placeholder: String
    private let isSecured: Bool
    private let accessibility: Accessibility
    private let onTextChange: (String) -> Void

    public init(
        title: String,
        placeholder: String,
        isSecured: Bool = false,
        accessibility: Accessibility,
        onTextChange: @escaping (String) -> Void
    ) {
        self.title = title
        self.placeholder = placeholder
        self.isSecured = isSecured
        self.accessibility = accessibility
        self.onTextChange = onTextChange
    }

    public var body: some View {
        CustomTitleAndCustomTextFieldWithBinding(
            title: title,
            placeholder: placeholder,
            inputText: $inputText,
            isSecured: isSecured,
            accessibility: accessibility,
            onTextChange: onTextChange
        )
    }
}

public struct CustomTitleAndCustomTextFieldWithBinding: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var inputText: String

    private let title: String // Title value
    private let placeholder: String
    private let isSecured: Bool
    private let accessibility: Accessibility
    private let onTextChange: (String) -> Void

    public init(
        title: String,
        placeholder: String,
        inputText: Binding<String>,
        isSecured: Bool = false,
        accessibility: Accessibility,
        onTextChange: @escaping (String) -> Void = { _ in }
    ) {
        self._inputText = inputText
        self.title = title
        self.placeholder = placeholder
        self.accessibility = accessibility
        self.isSecured = isSecured
        self.onTextChange = onTextChange
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
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
        }.onChange(of: inputText) { newValue in
            Common.ExecutionControlManager.debounce(1, operationId: "\(Self.self)\(#function)") {
                onTextChange(newValue)
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack {
        CustomTitleAndCustomTextFieldWithBinding(
            title: "title",
            placeholder: "placeholder",
            inputText: .constant("inputText"),
            accessibility: .undefined, onTextChange: { newText in
                DevTools.Log.debug(newText, .generic)
            }
        )
        CustomTitleAndCustomTextFieldWithState(
            title: "title",
            placeholder: "placeholder",
            accessibility: .undefined
        ) { newText in
            DevTools.Log.debug(newText, .generic)
        }
    }
}
#endif
