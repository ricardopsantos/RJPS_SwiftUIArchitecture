//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

public struct HideNavigationBar: ViewModifier {
    public func body(content: Content) -> some View {
        content.navigationBarTitle("", displayMode: .inline)
    }
}

public extension View {
    func hideNavigationBar() -> some View {
        modifier(HideNavigationBar())
    }
}

#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.ViewsModifiersTestView()
}
#endif
