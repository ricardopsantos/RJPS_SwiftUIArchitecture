//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// MARK: - ResignKeyboardOnDragGesture
//

public struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged { _ in
        UIApplication.shared.dismissKeyboard()
    }

    public func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

public extension View {
    func onDragDismissKeyboardV1() -> some View {
        modifier(ResignKeyboardOnDragGesture())
    }
}


#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.ViewsModifiersTestView()
}
#endif
