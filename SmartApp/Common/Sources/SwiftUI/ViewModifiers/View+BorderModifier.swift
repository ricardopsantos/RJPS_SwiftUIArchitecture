//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// MARK: - BorderModifier
//
public struct BorderModifier: ViewModifier {
    let width: CGFloat
    let color: Color
    public func body(content: Content) -> some View {
        content.border(color, width: width)
    }
}

public extension View {
    func borderModifier(width: CGFloat, color: Color) -> some View {
        modifier(BorderModifier(width: width, color: color))
    }
}

#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.ViewsModifiersTestView()
}
#endif
