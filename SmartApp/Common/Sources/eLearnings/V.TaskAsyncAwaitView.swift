//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public extension SwiftUITipsAndTricks {
    struct TaskAsyncAwaitView: View {
        @State private var result: String = ""
        public var body: some View {
            VStack {
                Text(result).padding()
                Button("Tap Me") {
                    Task {
                        do {
                            let data = try await fetchData()
                            result = String(data: data, encoding: .utf8) ?? "No data"
                        } catch {
                            result = "Error: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }

        func fetchData() async throws -> Data {
            let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
public struct SwiftUITipsAndTricks_TaskAsyncAwaitView: PreviewProvider {
    public static var previews: some View {
        SwiftUITipsAndTricks.TaskAsyncAwaitView().buildPreviews()
    }
}
#endif
