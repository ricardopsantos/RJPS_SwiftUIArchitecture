//
//  DatePickerPopover.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI

struct DatePickerPopover: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    @Binding var dateSelection: Date
    let title: String
    let doneButtonLabel: String

    var body: some View {
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
        isPresented: .constant(true),
        dateSelection: .constant(Date()),
        title: "Title",
        doneButtonLabel: "Done"
    )
}
