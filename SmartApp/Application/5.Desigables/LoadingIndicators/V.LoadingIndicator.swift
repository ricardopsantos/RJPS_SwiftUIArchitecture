//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Common

struct LoadingIndicator: View {
    @Environment(\.colorScheme) var colorScheme

    let isLoading: Bool
    let loadingMessage: String

    public init(isLoading: Bool, loadingMessage: String) {
        self.isLoading = isLoading
        self.loadingMessage = loadingMessage
    }

    public var body: some View {
        Group {
            if isLoading {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            // NB: There seems to be a bug in SwiftUI where the progress view does not show
                            // a second time unless it is given a new identity.
                            .id(UUID())
                        Text(loadingMessage)
                            .foregroundColorSemantic(.labelPrimary)
                            .fontSemantic(.caption)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                EmptyView()
            }
        }
        .ignoresSafeArea()
    }
}

//
// MARK: - Preview
//
#Preview {
    LoadingIndicator(isLoading: true, loadingMessage: "loadingMessage")
}
