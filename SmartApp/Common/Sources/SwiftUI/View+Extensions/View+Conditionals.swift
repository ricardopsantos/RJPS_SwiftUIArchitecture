//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// MARK: - Conditionals and Builder
// https://medium.com/better-programming/swiftui-tips-and-tricks-c7840d8eb01b
// https://matteo-puccinelli.medium.com/conditionally-apply-modifiers-in-swiftui-51c1cf7f61d1
//

public extension View {
    // Executes a closure and returns the original view.
    // Useful for side effects that don't alter the view structure.
    func performAndReturnSelf(_ block: () -> Void) -> some View {
        block()
        return self
    }

    // Executes a closure and returns an empty view.
    // Can be used when you need to trigger some side effects without displaying any content.
    func performAndReturnEmpty(_ block: () -> Void) -> some View {
        block()
        return EmptyView()
    }

    // Executes a closure if the condition is true, then returns an empty view.
    // Useful when you want to conditionally trigger side effects without rendering content.
    func performAndReturnEmpty(if condition: Bool, _ block: () -> Void) -> some View {
        if condition {
            block()
        }
        return EmptyView()
    }

    // Executes a closure and returns an empty view if running on a simulator.
    // This is handy for code that should only run during simulator testing.
    func performAndReturnEmptyIfSimulator(_ block: () -> Void) -> some View {
        performAndReturnEmpty(if: Common_Utils.onSimulator, block)
    }

    // Applies a transformation to the view if running on a simulator, otherwise returns the original view.
    // Useful for applying simulator-specific modifications to views.
    func ifOnSimulator(then transform: (Self) -> some View) -> some View {
        Common_Utils.onSimulator ? transform(self).erasedToAnyView : erasedToAnyView
    }

    // Conditionally applies one of two transformations to the view based on a condition.
    // The trueContent transformation is applied if the condition is true, else falseContent is applied.
    @ViewBuilder
    func ifElseCondition(
        _ condition: @autoclosure () -> Bool,
        then trueContent: (Self) -> some View,
        else falseContent: (Self) -> some View
    ) -> some View {
        if condition() {
            trueContent(self)
        } else {
            falseContent(self)
        }
    }

    // Conditionally applies a transformation to the view if the condition is true.
    // If the condition is false, the original view is returned.
    @ViewBuilder
    func ifCondition(
        _ condition: Bool,
        then trueContent: (Self) -> some View
    ) -> some View {
        ifElseCondition(condition, then: trueContent, else: { _ in self })
    }

    // Applies a transformation to the view based on a condition.
    // If the condition is false, the original view is returned.
    // This method also erases the view type to AnyView, providing flexibility in the view's return type.
    @ViewBuilder
    func doIf(
        _ condition: @autoclosure () -> Bool,
        transform: (Self) -> some View
    ) -> some View {
        ifCondition(condition(), then: transform).erased
    }

    // A backwards-compatible wrapper around the `onChange` modifier.
    // Triggers a callback whenever the specified value changes.
    @ViewBuilder
    func onChangeBackwardsCompatible<T: Equatable>(of value: T, perform completion: @escaping (T) -> Void) -> some View {
        onChange(of: value, perform: completion)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct SampleViewsConditionals: View {
        @State private var condition = true
        public init() {}
        public var body: some View {
            VStack {
                VStack {
                    Text(".doIf(condition)")
                    Image.systemHeart
                        .doIf(condition) { $0.rotate(degrees: 90) }
                }
                VStack {
                    Text(".ifOnSimulator")
                    Image.systemHeart
                        .ifOnSimulator { $0.foregroundColor(Color(.red)) }
                }
                VStack {
                    Text(".ifCondition(condition)")
                    Image.systemHeart
                        .ifCondition(condition) { $0.foregroundColor(Color(.blue)) }
                }
                VStack {
                    Text(".ifElseCondition(condition)")
                    Image.systemHeart
                        .ifElseCondition(condition) { $0.foregroundColor(Color(.blue)) } else: { $0.foregroundColor(Color(.green)) }
                }
                VStack {
                    // swiftlint:disable logs_rule_1
                    performAndReturnEmptyIfSimulator { Common_Logs.debug("perfomed_1") }
                    performAndReturnEmpty { Common_Logs.debug("perfomed_2") }
                    performAndReturnEmpty(if: condition) { Common_Logs.debug("perfomed_3") }
                    // swiftlint:enable logs_rule_1
                }
                Divider()
                Button("Tap me") { condition.toggle() }
                Spacer()
            }
        }
    }
}

#Preview {
    Common_Preview.SampleViewsConditionals()
}

#endif
