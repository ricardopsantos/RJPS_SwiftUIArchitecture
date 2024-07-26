//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import SwiftUI
import UIKit
import Foundation

/**
 In SwiftUI, `PreferenceKey` is a protocol that allows you to define
 and collect data from views during the layout phase, and then use that data to modify the behaviour of other views.
 */

// https://augmentedcode.io/2020/05/10/setting-an-equal-width-to-text-views-in-swiftui/

public extension Common {
    struct EqualWidthPreferenceKey: PreferenceKey {
        public typealias Value = CGFloat
        public static var defaultValue: CGFloat = 0
        public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

public extension Common {
    struct WidthViewModifier: ViewModifier {
        let width: Binding<CGFloat?>
        let identifier: String
        public func body(content: Content) -> some View {
            content
                .frame(width: width.wrappedValue)
                .background(GeometryReader { proxy in
                    // The background view modifier is used for layering GeometryReader
                    // behind the content view which avoids GeometryReader to affect the layout
                    //
                    // Transparent color view is only used for producing a value for
                    // the preference key which is then set to the binding in the
                    // preference key change callback
                    Color.clear.preference(
                        key: Common.EqualWidthPreferenceKey.self,
                        value: proxy.size.width
                    )
                    .performAndReturnSelf {
                        Common.LogsManager.debug("\(Self.self).\(identifier).width: \(proxy.size.width)")
                    }
                }).onPreferenceChange(Common.EqualWidthPreferenceKey.self) { value in
                    // On preference changed, set width
                    let newValue = max(width.wrappedValue ?? 0, value)
                    if newValue != width.wrappedValue {
                        Common.LogsManager.debug("\(Self.self).\(identifier).newMax: \(newValue)")
                        width.wrappedValue = newValue
                    }
                }
        }
    }
}

//
// MARK: - Preview
//
#if canImport(SwiftUI) && DEBUG
enum Commom_Previews_EqualWidthModifier {
    struct SampleEqualWidthModifier: View {
        @State private var maxWidth: CGFloat?
        @State private var textA: String = Self.randomStringGenerator()
        @State private var textB: String = Self.randomStringGenerator()
        @State private var textC: String = Self.randomStringGenerator()
        var body: some View {
            VStack {
                Button(
                    action: {
                        textA = Self.randomStringGenerator()
                        textB = Self.randomStringGenerator()
                        textC = Self.randomStringGenerator()
                        maxWidth = nil
                    },
                    label: { Text("Change text") }
                )
                Divider()
                TextBubble(text: textA, width: $maxWidth, identifier: "textA")
                TextBubble(text: textB, width: $maxWidth, identifier: "textB")
                TextBubble(text: textC, width: $maxWidth, identifier: "textC")
                Divider()
                Spacer()
            }.padding()
        }

        static func randomStringGenerator() -> String {
            String.random(Int.random(in: 1...25))
        }
    }

    struct TextBubble: View {
        let text: String
        let width: Binding<CGFloat?>
        let identifier: String

        var body: some View {
            VStack {
                Text(text)
                Text("\(Int(width.wrappedValue ?? 0))")
            }
            .modifier(Common.WidthViewModifier(width: width, identifier: identifier))
            .padding()
            .background(Color.random)
            .cornerRadius(8)
        }
    }

    public struct Preview: PreviewProvider {
        public static var previews: some View {
            SampleEqualWidthModifier().buildPreviews()
        }
    }
}
#endif
