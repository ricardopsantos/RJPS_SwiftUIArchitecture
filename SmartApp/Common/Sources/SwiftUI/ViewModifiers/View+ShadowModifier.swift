//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// MARK: - ShadowModifier
//

public struct ShadowModifier: ViewModifier {
    public init () { }
    public func body(content: Content) -> some View {
        content
            .shadow(color: .black, radius: 10)
    }
}

#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.ViewsModifiersTestView()
}
#endif
