//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import SwiftUI
import UIKit
import Foundation

public extension Common {
    struct EqualWidthPreferenceKey: PreferenceKey {
        public static var defaultValue: CGFloat = 0
        public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    struct CustomWidthViewModifier: ViewModifier {
        var width: CGFloat?
        public func body(content: Content) -> some View {
            if width ?? 0 == 0 {
                content
            } else {
                content
                    .frame(width: width)
            }
        }
    }

    struct EqualWidthViewModifier: ViewModifier {
        let width: Binding<CGFloat?>
        public func body(content: Content) -> some View {
            Group {
                if width.wrappedValue == 0 {
                    content
                } else {
                    content
                        .frame(width: width.wrappedValue)
                }
            }
            .background(GeometryReader { proxy in
                Color.clear.preference(
                    key: Common.EqualWidthPreferenceKey.self,
                    value: proxy.size.width
                )
            }).onPreferenceChange(Common.EqualWidthPreferenceKey.self) { value in
                Common_Logs.debug("\(Common.EqualWidthPreferenceKey.self): \(value)")
                let newValue = max(width.wrappedValue ?? 0, value)
                if newValue != width.wrappedValue {
                    width.wrappedValue = newValue
                }
            }
        }
    }
}

//
// MARK: - Test/Usage View
//

private func randomString() -> String {
    String.random(Int.random(in: 1...25))
}

struct TextBubble: View {
    let text: String
    let width: Binding<CGFloat?>
    var body: some View {
        VStack {
            Text(text)
            Text("\(Int(width.wrappedValue ?? 0))")
        }
        .modifier(Common.EqualWidthViewModifier(width: width))
        .padding()
        .background(Color.random)
        .cornerRadius(8)
    }
}

struct EqualWidthPreferenceKeyTestView: View {
    @State private var maxWidth: CGFloat?
    @State private var textA: String = randomString()
    @State private var textB: String = randomString()
    @State private var textC: String = randomString()
    var body: some View {
        VStack {
            Button(
                action: {
                    textA = randomString()
                    textB = randomString()
                    textC = randomString()
                    maxWidth = nil
                },
                label: { Text("Change text") }
            )
            Divider()
            TextBubble(text: textA, width: $maxWidth)
            TextBubble(text: textB, width: $maxWidth)
            TextBubble(text: textC, width: $maxWidth)
            Divider()
            Spacer()
        }.padding()
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview("CustomWidthViewModifier") {
    VStack {
        CommonLearnings.TwoViewSameSizeProblemSolution1()
        Divider()
        CommonLearnings.TwoViewSameSizeProblemSolution2()
        Divider()
        CommonLearnings.TwoViewSameSizeProblemSolution3()
        Divider()
        CommonLearnings.TwoViewSameSizeProblemSolution4()
    }
}

#Preview("EqualWidthPreferenceKeyTestView") {
    EqualWidthPreferenceKeyTestView()
}
#endif
