//
//  AppearanceSelectionView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/05/2024.
//

import Foundation
import SwiftUI
import Common

struct AppearanceSelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedMode: Common.InterfaceStyle?

    var body: some View {
        HStack {
            Text("Appearance".localizedMissing)
            Spacer()
            Picker("Appearance".localizedMissing, selection: $selectedMode) {
                Text("System".localizedMissing).tag("system")
                Text("Light".localizedMissing).tag(Common.InterfaceStyle.light)
                Text("Dark".localizedMissing).tag(Common.InterfaceStyle.dark)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedMode) { newValue in
                InterfaceStyle.current = newValue
            }
        }
        .foregroundColor(.labelPrimary)
    }
}

#Preview {
    AppearanceSelectionView(selectedMode: .constant(.dark))
}
