//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// MARK: - View (Animation)
//

public extension View {
    @inlinable func easeInOutAnimation() -> some View {
        animation(
            .easeInOut(duration: Common.Constants.defaultAnimationsTime)
                .repeatForever(autoreverses: false),
            value: 1.5
        )
    }

    @inlinable func springAnimation() -> some View {
        animation(
            .spring,
            value: 1.5
        )
    }

    @inlinable func linearAnimation() -> some View {
        animation(
            .linear(duration: Common.Constants.defaultAnimationsTime),
            value: 1.5
        )
    }

    @inlinable func defaultAnimation() -> some View {
        animation(
            .linear(duration: Common.Constants.defaultAnimationsTime),
            value: 1.5
        )
    }
}
