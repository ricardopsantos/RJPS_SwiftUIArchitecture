//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

public struct LoaderView: View {
    @Environment(\.colorScheme) var colorScheme
    public var isLoading = true
    public var body: some View {
        if isLoading {
            VStack {
                ProgressView()
            }
            .padding()
            .padding()
            .padding()
            .background(.background)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.gray.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

public struct LoaderViewModifier: ViewModifier {
    var isLoading: Bool
    public func body(content: Content) -> some View {
        content
            .overlay(LoaderView(isLoading: isLoading))
    }
}

extension View {
    func loading(_ value: Bool) -> some View {
        modifier(LoaderViewModifier(isLoading: value))
    }
}

#if canImport(SwiftUI) && DEBUG
#Preview {
    Common_Preview.ViewsModifiersTestView()
}
#endif
