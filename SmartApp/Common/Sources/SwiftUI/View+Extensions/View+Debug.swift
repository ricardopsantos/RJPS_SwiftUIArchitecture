//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

//
// MARK: - Debug
//

public extension View {
    // https://stackoverflow.com/questions/56517813/how-to-print-to-xcode-console-in-swiftui
    func debugPrint(_ vars: Any..., function: String = #function) -> some View {
        #if DEBUG
        let wereWasIt = function
        // swiftlint:disable logs_rule_1
        for some in vars { print("\(some) @ [\(wereWasIt)]") }
        // swiftlint:enable logs_rule_1
        return self
        #else
        return self
        #endif
    }

    func debugPrintOnReload(ifCondition: Bool, id: String, function: String = #function) -> some View {
        #if DEBUG
        return Group {
            if !ifCondition {
                self.erased
            } else {
                debugPrint("[\(id)] was reloaded at [\(Date.userDate)]", function: function)
            }
        }.erased
        #else
        return self
        #endif
    }

    func debugPrintOnReload(id: String, function: String = #function) -> some View {
        debugPrint("[\(id)] was reloaded at [\(Date.userDate)]", function: function)
    }
}

//
// MARK: - Previews
//

public extension View {
    var buildPreviewPhone11: some SwiftUI.View {
        previewDevice("iPhone 11").previewDisplayName("Default - iPhone11")
    }

    var buildPreviewPhone15: some SwiftUI.View {
        previewDevice("iPhone 15").previewDisplayName("Default - iPhone15")
    }

    var buildPreviewDark: some SwiftUI.View {
        environment(\.colorScheme, .dark).previewDisplayName("Dark")
    }

    func buildPreviews(full: Bool = false) -> some SwiftUI.View {
        Group {
            if full {
                Group {
                    environment(\.colorScheme, .light).previewDisplayName("Light")
                    environment(\.colorScheme, .dark).previewDisplayName("Dark")
                }
                /* Group {
                     buildPreviewPhone8()
                     buildPreviewPhone11()
                 } */
                Group {
                    environment(\.sizeCategory, .small).previewDisplayName("Size_Small")
                    environment(\.sizeCategory, .large).previewDisplayName("Size_Large")
                    environment(\.sizeCategory, .extraLarge).previewDisplayName("Size_ExtraLarge")
                }
            } else {
                Group {
                    environment(\.colorScheme, .light).previewDisplayName("Light")
                    environment(\.colorScheme, .dark).previewDisplayName("Dark")
                }
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct SampleViewsDebug: View {
        public init() {}
        public var body: some View {
            VStack {
                debugPrint("123")
                debugPrintOnReload(id: "id")
                debugPrintOnReload(ifCondition: true, id: "id")
            }
        }
    }
}

#Preview {
    Common_Preview.SampleViewsDebug()
}

#endif
