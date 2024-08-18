//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Combine
import Foundation

public extension Error {
    var finishedWithoutValue: Bool {
        if let asyncError = self as? AsyncError, asyncError == .finishedWithoutValue {
            return true
        }
        return false
    }
}

public enum AsyncError: Error {
    case finishedWithoutValue
}

public extension AnyPublisher {
    @discardableResult
    func async(sender: String = #function) async throws -> Output {
        try await asyncAttached(sender: sender)
    }

    @discardableResult
    func asyncAttached(sender: String) async throws -> Output {
        // - Parent-Child Relationship: Non-detached tasks establish a parent-child relationship.
        //   If a non-detached task is created within another task, the parent task will wait for the
        //   child task to complete before continuing its execution.
        // - Concurrency: Non-detached tasks run concurrently within their parent task.
        //   They allow you to break down your asynchronous code into smaller, manageable tasks without losing the sequential execution flow.
        try await asyncJust(sender: sender, firstEmission: true)
    }

    @discardableResult
    func asyncDetached(sender: String) async throws -> Output {
        // - Parent-Child Relationship: Detached tasks do not establish a parent-child relationship with the code that spawns them.
        //   This means that a detached task can outlive its parent task or the scope it was created in.
        //   The parent task doesn't wait for the detached task to complete.
        // - Concurrency: Detached tasks can run concurrently, and the program flow does not wait for their completion.
        //   They operate independently and asynchronously from the code that spawned them.
        try await Task.detached {
            try await async()
        }.value
    }

    @discardableResult
    func asyncJust(sender: String, firstEmission: Bool = true) async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = (firstEmission ? first().eraseToAnyPublisher() : last().eraseToAnyPublisher())
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            Common_Logs.error("\(sender) : Finish without value - \(continuation)")
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}

//
// MARK: - AsyncStream
//

/**
 AsyncStream is a new feature introduced in Swift 5.5, which provides a simple and efficient way to work with streams of data asynchronously.
 It is a type that allows you to send and receive a sequence of values over time in an asynchronous and non-blocking manner.

 AsyncStream has a number of advantages over traditional streams, such as being able to handle asynchronous operations, avoiding
 blocking and waiting for data to be available, and reducing the amount of boilerplate code required to work with streams. It is also
 designed to work seamlessly with other Swift concurrency features such as async/await, actors, and structured concurrency.

 ```
 // Create an AsyncStream that produces integers
 func generateNumbers() -> AsyncStream<Int> {
     return AsyncStream { continuation in
         // Start a background task that generates numbers
         Task {
             for i in 0..<10 {
                 // Yield the next number
                 continuation.yield(i)
             }
             // Mark the end of the stream
             continuation.finish()
         }
     }
 }

 // Consume the numbers
 Task {
     for await number in generateNumbers() {
         debugPrint(number)
     }
 }
 ```

 In this example, we create an AsyncStream that generates the numbers 0 to 9, and then use a for await loop to consume those numbers and print them to the console.
 */

public extension AnyPublisher where Failure == Never {
    func stream(canFail: Bool = false) -> AsyncStream<Output> {
        .init { continuation in
            let cancellable = self
                .eraseToAnyPublisher()
                .sink { completion in
                    switch completion {
                    case .finished:
                        continuation.finish()
                    case let .failure(never):
                        if canFail {
                            continuation.yield(with: .failure(never))
                        } else {
                            continuation.finish() // Treat the error as completion
                            // In this modified version of the stream extension, if the AnyPublisher has a failure event,
                            // it will be treated as a completion event (i.e., the stream will finish) rather than yielding
                            // the error. This effectively ignores the error and allows your code to continue executing.
                        }
                    }
                } receiveValue: { output in
                    continuation.yield(output)
                }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

public extension AnyPublisher where Failure == Error {
    var throwingStream: AsyncThrowingStream<Output, Failure> {
        .init { continuation in
            let cancellable = self
                .eraseToAnyPublisher()
                .sink { completion in
                    switch completion {
                    case .finished:
                        continuation.finish()
                    case let .failure(error):
                        continuation.finish(throwing: error)
                    }
                } receiveValue: { output in
                    continuation.yield(output)
                }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
