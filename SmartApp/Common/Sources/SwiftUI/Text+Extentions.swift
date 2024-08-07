//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

public extension View {
    func textColor(_ color: Color?) -> some View {
        foregroundColor(color)
    }
}

public extension Text {
    func textColor(_ color: Color?) -> some View {
        foregroundColor(color)
    }
}

public extension TextField {
    func textColor(_ color: Color?) -> some View {
        foregroundColor(color)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
fileprivate extension Common_Preview {
    struct TextExtensions: View {
        public init() {}
        @State var string: String = "string"
        public var body: some View {
            VStack {
                Text("Text").textColor(.red)
                TextField("TextField", text: $string).textColor(.red)
            }
        }
    }
}

#Preview {
    Common_Preview.TextExtensions()
}

#endif
