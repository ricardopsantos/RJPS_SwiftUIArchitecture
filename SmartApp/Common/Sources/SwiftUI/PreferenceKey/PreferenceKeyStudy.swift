//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public extension Common {
    struct ColorSchemePreferenceKey: PreferenceKey {
        public static var defaultValue: ColorScheme?
        public static func reduce(value: inout ColorScheme?, nextValue: () -> ColorScheme?) {
            value = value ?? nextValue()
        }
    }

    struct IntSumPreferenceKey: PreferenceKey {
        public static var defaultValue: Int = 0
        public static func reduce(value: inout Int, nextValue: () -> Int) {
            value += nextValue()
        }
    }
}

//
// MARK: - Test/Usage View
//
struct PreferenceKeyStudyTestView: View {
    @State private var colorScheme: ColorScheme = .light
    @State private var myPreferenceValue: String = "123"
    @State private var frameHeight: CGFloat = 20

    var body: some View {
        VStack {
            Text("Hello, World!")
                .preference(
                    key: Common.ColorSchemePreferenceKey.self,
                    value: .light
                ) // SET Preference
                .background(colorScheme == .light ? Color.green : Color.red)
            Divider()
            Button("Increment frameHeight") {
                frameHeight += 5
            }
            Text("Counter value: \(frameHeight)")
                .padding()
                .frame(height: frameHeight)
                .background(GeometryReader { _ in
                    Color.blue.preference(
                        key: Common.IntSumPreferenceKey.self,
                        value: Int(frameHeight)
                    ) // SET Preference
                })
                .background(Color.red)
            Spacer()
        }
        .onPreferenceChange(Common.ColorSchemePreferenceKey.self) { value in
            colorScheme = value ?? .light
            Common_Logs.debug("\(Common.ColorSchemePreferenceKey.self): \(String(describing: value))")
        }
        .onPreferenceChange(Common.IntSumPreferenceKey.self) { value in
            Common_Logs.debug("\(Common.IntSumPreferenceKey.self): \(value)")
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    PreferenceKeyStudyTestView()
}
#endif
