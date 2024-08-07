//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// @Binding property: a two-way connection to a state owned by someone else.
// Can be updated by both and changes to it will trigger updates on both views.

public extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        didSet(handler)
    }

    func didSet(_ handler: @escaping (Value) -> Void) -> Binding {
        Binding(
            get: { wrappedValue },
            set: {
                wrappedValue = $0
                handler($0)
            }
        )
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct BindingExtensions: View {
        public init() {}
        @State var doubleValue: Double = 0
        @State var boolValue: Bool = false
        public var body: some View {
            VStack {
                Slider(value: $doubleValue.onChange(doubleValueChanged), in: 0...100, step: 1)
                Toggle("Hi", isOn: $boolValue.didSet { state in
                    // swiftlint:disable logs_rule_1
                    Common.LogsManager.debug("\(state)")
                    // swiftlint:enable logs_rule_1
                })
            }
        }

        func doubleValueChanged(to value: Double) {
            // swiftlint:disable logs_rule_1
            Common.LogsManager.debug("Changed to \(value)!")
            // swiftlint:enable logs_rule_1
        }
    }
}

#Preview {
    Common_Preview.BindingExtensions()
}

#endif
