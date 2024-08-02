//
//  DatePickerPopover.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI

public struct DatePickerPopover: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    @Binding var dateSelection: Date
    private let title: String
    private let doneButtonLabel: String

    public init(
        title: String,
        doneButtonLabel: String,
        isPresented: Binding<Bool>,
        dateSelection: Binding<Date>
    ) {
        self._isPresented = isPresented
        self._dateSelection = dateSelection
        self.title = title
        self.doneButtonLabel = doneButtonLabel
    }

    public var body: some View {
        VStack {
            DatePicker(
                title,
                selection: $dateSelection,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()
            .frame(maxHeight: 400)
            Button(doneButtonLabel) {
                isPresented = false
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    DatePickerPopover(
        title: "Title",
        doneButtonLabel: "Done",
        isPresented: .constant(true),
        dateSelection: .constant(Date())
    )
}
