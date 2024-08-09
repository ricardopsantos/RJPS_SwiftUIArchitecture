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
    struct ViewsModifiersSampleView: View {
        var body: some View {
            Text("Hello World")
        }
    }
    struct ViewsModifiersTestView: View {
        public init() {}
        @State var viewFrame: (CGRect, CGRect) = (.zero, .zero)
        public var body: some View {
            VStack {
                ViewsModifiersSampleView()
                    .modifier(ShadowModifier())
                Divider()
                ViewsModifiersSampleView()
                    .modifier(BorderModifier(width: 2, color: .red))
                Divider()
                //ViewsModifiersTestView()
                //    .modifier(ShadowModifier())
                Divider()
              //  ViewsModifiersTestView()
               //     .modifier(LoaderViewModifier(isLoading: .true))
                Divider()
               // ViewsModifiersTestView()
               //     .modifier(AnimatedBackground())
                Divider()
               // ViewsModifiersTestView()
               //     .modifier(ResignKeyboardOnDragGesture())
            }
        }
    }
}

#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.ViewsModifiersTestView()
}
#endif
