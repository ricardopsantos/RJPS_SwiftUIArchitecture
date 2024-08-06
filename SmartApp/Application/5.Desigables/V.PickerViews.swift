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
    @Binding var selected: String
    private static var systemValue: String { "system" }
    public init(selected: Binding<Common.InterfaceStyle?>) {
        _selected = Binding(
            get: { selected.wrappedValue?.rawValue ?? Self.systemValue },
             set: { newValue in
                 selected.wrappedValue = Common.InterfaceStyle(rawValue: newValue)
             }
         )
    }

    public var body: some View {
        HStack {
            Text("Appearance".localizedMissing)
            Spacer()
            Picker("Appearance".localizedMissing, selection: $selected) {
                Text("System".localizedMissing).tag(Self.systemValue)
                Text("Light".localizedMissing).tag(Common.InterfaceStyle.light.rawValue)
                Text("Dark".localizedMissing).tag(Common.InterfaceStyle.dark.rawValue)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selected) { newValue in
                InterfaceStyleManager.current = .init(rawValue: newValue)
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
