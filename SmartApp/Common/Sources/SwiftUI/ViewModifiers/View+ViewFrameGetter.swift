//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

// https://izziswift.com/get-width-of-a-view-using-in-swiftui/
struct ViewFrameGetter: ViewModifier {
    @Binding var rects: (CGRect, CGRect)
    public func body(content: Content) -> some View {
        GeometryReader { g -> Color in // (g) -> Content in - is what it could be, but it doesn't work
            DispatchQueue.executeInMainTread { // to avoid warning
                rects = (g.frame(in: .local), g.frame(in: .global))
            }
            return Color.clear // return content - doesn't work
        }
    }

    static func sampleUsage() -> any View {
        @State var viewFrame: (CGRect, CGRect) = (.zero, .zero)
        let result2 = Text("").overlay(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    Common_Logs.debug("First HEIGHT: \(proxy.size.height)")
                }
            })
        // p rint(viewFrame)
        return result2
    }
}

#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.ViewsModifiersTestView()
}
#endif
