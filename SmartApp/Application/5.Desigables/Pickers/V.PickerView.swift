//
//  PickerView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import DesignSystem
import Core

struct CountryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedCountry: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("SelectCountry".localizedMissing)
                    .fontSemantic(.body)
                    .foregroundColor(.labelPrimary)
                Picker(
                    "SelectCountryPlaceHolder".localizedMissing,
                    selection: $selectedCountry
                ) {
                    ForEach(AppConstants.countriesOptions, id: \.self) {
                        country in
                        Text(country.localized)
                    }
                }
                .pickerStyle(DefaultPickerStyle())

                Spacer()
            }
        }
    }
}

struct GenderView: View {
    @Binding var selectedGender: Gender
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gender".localizedMissing)
                .fontSemantic(.body)
                .foregroundColor(.labelPrimary)
            Picker("GenderPlaceHolder".localizedMissing, selection: $selectedGender) {
                ForEach(Gender.allCases) { gender in
                    Text(gender.rawValue.localizedMissing).tag(gender)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

#Preview {
    VStack {
        CountryView(selectedCountry: .constant("UK"))
        GenderView(selectedGender: .constant(.female))
    }
}
