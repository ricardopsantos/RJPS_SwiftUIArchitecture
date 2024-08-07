//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public struct SafeAreaInsetsKey: EnvironmentKey {
    public typealias Value = EdgeInsets
    public static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }

    public static var defaultValue: EdgeInsets {
        (UIApplication.keyWindow?.safeAreaInsets ?? .zero).insets
        // (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }

    public static var defaultValueV2: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

private extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

public extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
struct SafeAreaInsetsView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme

    var safeAreaInsetsValue: String { "\(safeAreaInsets)" }
    var horizontalSizeClassValue: String { "\(String(describing: horizontalSizeClass))" }
    var verticalSizeClassValue: String { "\(String(describing: verticalSizeClass))" }
    var colorSchemeValue: String { "\(colorScheme)" }

    var body: some View {
        VStack {
            Text("safeAreaInsetsValue: \(safeAreaInsetsValue)")
            Divider()
            Text("horizontalSizeClassValue: \(horizontalSizeClassValue)")
            Divider()
            Text("verticalSizeClassValue: \(verticalSizeClassValue)")
            Divider()
            Text("colorSchemeValue: \(colorSchemeValue)")
            Divider()
            Spacer()

        }.padding(safeAreaInsets)
    }
}

#Preview {
    SafeAreaInsetsView()
}

#endif
