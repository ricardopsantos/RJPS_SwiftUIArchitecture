//
//  AsyncAwait.swift
//  Common
//
//  Created by Ricardo Santos on 07/08/2024.
//

import Foundation
import SwiftUI

// https://blog.stackademic.com/async-and-await-in-swift-advanced-guide-for-senior-ios-developers-f753ce9a6cb0

public extension SwiftUITipsAndTricks {
    struct AsyncAwaitTestView: View {
        let url1 = "https://jsonplaceholder.typicode.com/todos/1"
        let url2 = "https://jsonplaceholder.typicode.com/todos/2"
        @State private var basicData: String = ""
        @State private var concurrentData: String = ""
        @State private var dataWithTimeout: String = ""
        @State private var dataWithGroup: String = ""
        @State private var dataWithDependency: String = ""
        public var body: some View {
            ScrollView {
                VStack {
                    Divider()
                    Text("basicData: \(basicData)")
                    Divider()
                    Text("concurrentData: \(concurrentData)")
                    Divider()
                    Text("dataWithTimeout: \(dataWithTimeout)")
                    Divider()
                    Text("dataWithGroup: \(dataWithGroup)")
                    Divider()
                    Text("dataWithDependency: \(dataWithDependency)")
                    Divider()
                }
            }
            .onAppear(perform: {
                Task {
                    do {
                        basicData = try await fetchData(from: url1).utf8String ?? ""

                        concurrentData = try await fetchConcurrentData().debugDescription

                        dataWithTimeout = try await fetchDataWithTimeout().utf8String ?? ""

                        dataWithGroup = try await fetchMultipleDataWithGroup(urls: [url1, url2]).compactMap(\.utf8String).description

                        dataWithDependency = try await fetchAndProcessData()

                    } catch {}
                }
            })
        }

        // Basic Example
        func fetchData(from url: String) async throws -> Data {
            guard let url = URL(string: url) else {
                throw URLError(.badURL)
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }

        // Concurrent Data Fetching
        // Suppose you need to fetch data from multiple URLs concurrently and process them together
        func fetchConcurrentData() async throws -> (Data, Data)? {
            async let data1 = fetchData(from: url1)
            async let data2 = fetchData(from: url2)

            do {
                return try await (data1, data2)
            } catch {}
            return nil
        }

        // Handling Timeouts and Cancellation
        // Handling timeouts and cancellations is crucial.
        func fetchDataWithTimeout() async throws -> Data {
            let task = Task {
                try await fetchData(from: url1)
            }

            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 5_000_000_000)
                task.cancel()
            }

            do {
                return try await task.value
            } catch {
                timeoutTask.cancel()
                throw error
            }
        }

        // Task groups allow you to create and manage a collection of tasks, providing better control over concurrency.
        func fetchMultipleDataWithGroup(urls: [String]) async throws -> [Data] {
            try await withThrowingTaskGroup(of: Data.self) { group in
                for url in urls {
                    group.addTask {
                        try await fetchData(from: url)
                    }
                }

                var results: [Data] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }
        }

        // asks may depend on the results of other tasks. The async and await model handles dependencies elegantly
        func fetchAndProcessData() async throws -> String {
            async let data1 = fetchData(from: url1)
            async let data2 = fetchData(from: url2)

            let result1 = try await data1.utf8String ?? ""
            let result2 = try await data2.utf8String ?? ""

            // Process the data
            let processedData = result1 + result2
            return processedData
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SwiftUITipsAndTricks.AsyncAwaitTestView()
}
#endif
