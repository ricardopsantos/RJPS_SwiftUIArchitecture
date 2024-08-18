//
//  Created by Ricardo Santos on 16/08/2024.
//

import Foundation
import SwiftUI

// https://blog.stackademic.com/swiftui-two-views-same-size-2-ways-603db1093913

private func randomString() -> String {
    let length = Int.random(in: 10..<30)
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
}

public extension CommonLearnings {
    struct TwoViewSameSizeProblem: View {
        public var body: some View {
            VStack(spacing: 30) {
                Text("short Text")
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue)
                    )
                Text("long Text long Text long Text long Text ")
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

public extension CommonLearnings {
    /**
     Let’s get started with the `FixedSize` Modifier. It is a really elegant way of making multiple views the same size but also has some limitations that I will be showing you shortly.

     The key idea of using this modifier is

     For views we want to size, set `.frame(maxWidth: .infinity)` or `.frame(maxHeight: .infinity)`
     For container view, apply `.fixedSize()`

     This will have SwiftUI figuring out the least amount of space the views need, then allows them to take up that full amount for us!

     __Limitation__
     This method is great, but I would also like to point out one limitation here in case that is something you concerned about.

     We cannot position the views with different alignments anymore.
     */
    struct TwoViewSameSizeProblemSolution1: View {
        public var body: some View {
            VStack(spacing: 30) {
                Text("short Text Solution1")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                Text("long Text long Text long Text ")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.white)
                    .background(Color.red)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }
}

public extension CommonLearnings {
    /**
     The basic idea here is to add our GeometryReader as a background or overlay.

     We will NOT want to wrap the entire Text within a GeometryReader
     as (you might have experienced already with it) it will mess up the entire layout.

     We will need to update our state within `DispatchQueue.main.async.`
     Otherwise, we will get [SwiftUI] Modifying state during view update, this will cause
     undefined behavior error.
     */
    struct TwoViewSameSizeProblemSolution2: View {
        @State var maxWidth: CGFloat = 0
        public var body: some View {
            VStack(spacing: 30) {
                Text("short Text Solution2 ")
                    .padding()
                    .foregroundStyle(Color.white)
                    .frame(width: maxWidth)
                    .background(Color.blue)

                Text("long Text long Text long Text ")
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(
                        GeometryReader { geometry in
                            DispatchQueue.main.async {
                                maxWidth = geometry.size.width
                            }
                            return Color.red
                        }
                    )
            }
        }
    }
}

extension CommonLearnings {
    struct TwoViewSameSizeProblemSolution3: View {
        @State var maxWidth: CGFloat = 0
        @State var textString: String = ""
        var body: some View {
            VStack(spacing: 30) {
                Text("short Text Solution3")
                    .padding()
                    .foregroundStyle(Color.white)
                    .modifier(Common.CustomWidthViewModifier(width: maxWidth))
                    .lineLimit(1)
                    .background(
                        GeometryReader { geometry in
                            DispatchQueue.main.async {
                                maxWidth = max(maxWidth, geometry.size.width)
                            }
                            return Color.blue
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(textString)
                    .padding()
                    .lineLimit(1)
                    .foregroundStyle(Color.white)
                    .modifier(Common.CustomWidthViewModifier(width: maxWidth))
                    .background(
                        GeometryReader { geometry in
                            DispatchQueue.main.async {
                                maxWidth = max(maxWidth, geometry.size.width)
                            }
                            return Color.red
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .onAppear {
                Common_Utils.delay(1) {
                    textString = randomString()
                    Common_Utils.delay(1) {
                        textString = randomString()
                        Common_Utils.delay(1) {
                            textString = randomString()
                        }
                    }
                }
            }
        }
    }
}

extension CommonLearnings {
    // Only works when the view starts already with the text
    struct TwoViewSameSizeProblemSolution4: View {
        @State var maxWidth: CGFloat?
        @State private var textA: String = "short text Solution4" {
            didSet {
                maxWidth = nil
            }
        }

        @State private var textB: String = randomString() {
            didSet {
                maxWidth = nil
            }
        }

        @State private var debug: String = ""
        var body: some View {
            VStack(spacing: 30) {
                Text(debug)
                Text(textA)
                    .foregroundStyle(Color.white)
                    .padding()
                    .lineLimit(1)
                    .modifier(Common.EqualWidthViewModifier(width: $maxWidth))
                    .background(Color.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(textB)
                    .foregroundStyle(Color.white)
                    .padding()
                    .lineLimit(1)
                    .modifier(Common.EqualWidthViewModifier(width: $maxWidth))
                    .background(Color.red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }.onAppear {
                Common_Utils.delay(1) {
                    textB = randomString()
                    Common_Utils.delay(1) {
                        textB = randomString()
                        Common_Utils.delay(1) {
                            textB = randomString()
                        }
                    }
                }
            }
        }
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
