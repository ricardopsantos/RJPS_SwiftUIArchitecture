//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

// https://medium.com/@alessandromanilii/swiftui-custom-modifier-84ce498b0112

/**
 In SwiftUI, a `ViewModifier`  is a method that returns a new version of the view it is called on,
 with additional behaviour or appearance. View modifiers are represented by functions that have the
 `modifier` suffix, and they can be chained together to create complex and reusable views.
 */

internal extension Common_Preview {
    struct ViewsModifiersTestView: View {
        public init() {}
        public var body: some View {
            VStack(spacing: 10) {
                Text("ShadowModifier").modifier(ShadowModifier())
                Divider()
                Text("BorderModifier").modifier(BorderModifier(width: 2, color: .red))
                Divider()
                Text("AnimatedBackground").modifier(AnimatedBackground())
                Divider()
                Text("ResignKeyboardOnDragGesture").modifier(ResignKeyboardOnDragGesture())
            }.modifier(LoaderViewModifier(isLoading: .false))
        }
    }
}

#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.ViewsModifiersTestView()
}
#endif
