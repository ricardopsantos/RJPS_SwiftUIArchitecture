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
    func performAndReturnSelf(_ block: () -> Void) -> some View {
        block()
        return self
    }

    func performAndReturnEmpty(_ block: () -> Void) -> some View {
        block()
        return EmptyView()
    }

    func performAndReturnEmpty(if condition: Bool, _ block: () -> Void) -> some View {
        if condition {
            block()
        }
        return EmptyView()
    }

    func performAndReturnEmptyIfSimulator(_ block: () -> Void) -> some View {
        performAndReturnEmpty(if: Common_Utils.onSimulator, block)
    }

    func ifOnSimulator(then transform: (Self) -> some View) -> some View {
        Common_Utils.onSimulator ? transform(self).erasedToAnyView : erasedToAnyView
    }

    @ViewBuilder // @ViewBuilder: A custom parameter attribute that constructs views from closures.
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

    @ViewBuilder // @ViewBuilder: A custom parameter attribute that constructs views from closures.
    func ifCondition(
        _ condition: Bool,
        then trueContent: (Self) -> some View
    ) -> some View {
        ifElseCondition(condition, then: trueContent, else: { _ in self })
    }

    @ViewBuilder
    func doIf(
        _ condition: @autoclosure () -> Bool,
        transform: (Self) -> some View
    ) -> some View {
        ifCondition(condition(), then: transform).erased
    }

    @ViewBuilder
    func onChangeBackwardsCompatible<T: Equatable>(of value: T, perform completion: @escaping (T) -> Void) -> some View {
        onChange(of: value, perform: completion)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
private extension Common_Preview {
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
                    performAndReturnEmptyIfSimulator { Common.LogsManager.debug("perfomed_1") }
                    performAndReturnEmpty { Common.LogsManager.debug("perfomed_2") }
                    performAndReturnEmpty(if: condition) { Common.LogsManager.debug("perfomed_3") }
                    // swiftlint:enable logs_rule_1
                }
                Divider()
                Button("Tap me") { condition.toggle() }
                Spacer()
            }
        }
    }
}

struct Common_Previews_ViewConditionals: PreviewProvider {
    public static var previews: some View {
        Common_Preview.SampleViewsConditionals().buildPreviews()
    }
}
#endif
