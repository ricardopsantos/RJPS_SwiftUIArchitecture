//
//  DatePickerPopover.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import DevTools

public struct DefaultSegmentedPickerView: View {
    public struct Option: Identifiable {
        public var id: String { tag }
        let value: String
        let tag: String
        public init(value: String, tag: String = "") {
            self.value = value
            self.tag = tag.isEmpty ? value : tag
        }
    }

    @Environment(\.colorScheme) var colorScheme
    @Binding var selected: String
    private let options: [Option]
    private let title: String
    public init(
        title: String,
        options: [Option],
        selected: Binding<String>
    ) {
        self.title = title
        self.options = options
        self._selected = selected
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontSemantic(.body)
                .foregroundColor(ColorSemantic.labelPrimary.color)
            Picker("", selection: $selected) {
                ForEach(options) { option in
                    Text(option.value).tag(option.tag)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack {
        DefaultSegmentedPickerView(
            title: "title",
            options: [
                .init(value: "Option 1"),
                .init(value: "Option 2"),
                .init(value: "Option 3")
            ],
            selected: .constant("Option 2")
        )
    }
}
#endif
