//
//  PickerView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Domain
import Core
import DesignSystem
import Common

public struct CountryPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selected: String
    public init(
        selected: Binding<String>) {
        self._selected = selected
    }

    public var body: some View {
        DefaultPickerView(
            title: "Country",
            options: AppConstants.countriesOptions,
            selectedOption: $selected)
    }
}

struct GenderPickerView: View {
    @Binding var selected: Gender
    var options: [DefaultSegmentedPickerView.Option] {
        Gender.allCases.map {
            DefaultSegmentedPickerView.Option(value: $0.rawValue, tag: "")
        }
    }

    var body: some View {
        DefaultSegmentedPickerView(
            title: "Gender",
            options: options,
            selected: Binding<String>(
                get: { selected.rawValue },
                set: { newValue in
                    if let newGender = Gender(rawValue: newValue) {
                        selected = newGender
                    }
                }))
    }
}

public struct AppearancePickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selected: Common.InterfaceStyle?

    public init(selected: Binding<Common.InterfaceStyle?>) {
        self._selected = selected
    }

    public var body: some View {
        HStack {
            Text("Appearance".localizedMissing)
            Spacer()
            Picker("Appearance".localizedMissing, selection: $selected) {
                Text("System".localizedMissing).tag("system")
                Text("Light".localizedMissing).tag(Common.InterfaceStyle.light)
                Text("Dark".localizedMissing).tag(Common.InterfaceStyle.dark)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selected) { newValue in
                InterfaceStyle.current = newValue
            }
        }
        .foregroundColor(.labelPrimary)
    }
}

#Preview {
    VStack {
        CountryPickerView(
            selected: .constant("Portugal"))
        GenderPickerView(selected: .constant(.female))
        AppearancePickerView(selected: .constant(.dark))
    }
}
