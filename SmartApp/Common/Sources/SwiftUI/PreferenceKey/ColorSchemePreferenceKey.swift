//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

//
// https://developer.apple.com/documentation/swiftui/preferencekey
//

/**
 In SwiftUI, `PreferenceKey` is a protocol that allows you to define
 and collect data from views during the layout phase, and then use that data to modify the behaviour of other views.

 `PreferenceKey` provides a way to define and manage user preferences in your application. It allows you to store and
 retrieve values from the user defaults, which is a persistent storage mechanism provided by Apple.

 To use a `PreferenceKey`, you need to define a custom type that conforms to the protocol. You then use this type to
 define a preference value in a view hierarchy. Any views that are descendants of this view can then access the preference
 value using the @Environment property wrapper.

 */

public extension Common {
    struct ColorSchemePreferenceKey: PreferenceKey {
        public typealias Value = ColorScheme?
        public static var defaultValue: ColorScheme?
        public static func reduce(value: inout ColorScheme?, nextValue: () -> ColorScheme?) {
            value = value ?? nextValue()
        }
    }
}

public extension Common {
    struct MyPreferenceSetterV1: PreferenceKey {
        public typealias Value = String
        public static var defaultValue: Value = ""
        public static func reduce(value: inout Value, nextValue: () -> Value) {
            // concatenate all values together
            value += nextValue()
        }
    }

    struct MyPreferenceSetterV2: PreferenceKey {
        public static var defaultValue: Int = 0
        public static func reduce(value: inout Int, nextValue: () -> Int) {
            value += nextValue()
        }
    }
}

/**
 In this example, the `ColorSchemePreferenceKey` is defined as a struct that conforms to
 the `PreferenceKey` protocol. It has a typealias Value that specifies the type of value that the key
 will store. In this case, we are storing a `ColorScheme`, which is an enum that represents light or dark mode.

 The defaultValue property specifies the default value of the preference key if no value has been set. In this case,
 the default value is nil.

 The reduce() method is used to combine multiple values of the preference key into a single value. In this example,
 we are using the default reduce behaviour, which takes the first non-nil value that is encountered.

 Once you have defined your PreferenceKey, you can use it in your view hierarchy like this:
 */

struct PreferenceKeyTestView: View {
    @State private var colorScheme: ColorScheme = .light
    @State private var myPreferenceValue: String = "123"
    @State private var counter: CGFloat = 20

    var body: some View {
        VStack {
            Text("Hello, World!")
                .preference(
                    key: Common.MyPreferenceSetterV1.self,
                    value: myPreferenceValue
                ) // SET Preference
                .preference(
                    key: Common.ColorSchemePreferenceKey.self,
                    value: .light
                ) // SET Preference
                .background(colorScheme == .light ? Color.white : Color.black)
            Divider()
            Button("Increment") {
                counter += 5
            }
            Text("Counter value: \(counter)")
                .padding()
                .frame(height: counter)
                .background(GeometryReader { _ in
                    Color.blue.preference(
                        key: Common.MyPreferenceSetterV2.self,
                        value: Int(counter)
                    ) // SET Preference
                })
                .background(Color.red)
            Spacer()
        }
        .onPreferenceChange(Common.ColorSchemePreferenceKey.self) { value in
            colorScheme = value ?? .light
            Common.LogsManager.debug("\(Common.ColorSchemePreferenceKey.self): \(String(describing: value))")
        }
        .onPreferenceChange(Common.MyPreferenceSetterV1.self) { value in
            Common.LogsManager.debug("\(Common.MyPreferenceSetterV1.self): \(value)")
        }
        .onPreferenceChange(Common.MyPreferenceSetterV2.self) { value in
            Common.LogsManager.debug("\(Common.MyPreferenceSetterV2.self): \(value)")
        }
    }
}

//
// MARK: - Preview
//
#if canImport(SwiftUI) && DEBUG
enum Commom_Previews_PreferenceKeyTestView {
    struct Preview: PreviewProvider {
        public static var previews: some View {
            PreferenceKeyTestView().buildPreviews()
        }
    }
}
#endif
