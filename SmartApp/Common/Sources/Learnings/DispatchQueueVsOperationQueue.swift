//
//  Created by Ricardo Santos on 15/08/2024.
//

import Foundation

// https://medium.com/@harshaag99/dispatchqueue-vs-operationqueue-in-swift-02a71626080f

struct DispatchQueueVsOperationQueue {
    static func dispatchQueue() {
        // Think of DispatchQueue as your speedy barista. When a customer places
        // an order, the barista quickly handles each task one by one, either on
        // a first-come-first-serve basis or as a background task.
        //
        // When to Use DispatchQueue?
        //  - When you need simple concurrency.
        //  - When tasks are independent of each other.
        //  - When you need to update the UI on the main thread.
        let queue = DispatchQueue(label: "com.cafe.orderQueue")

        queue.async {
            print("Taking order from customer 1")
        }

        queue.async {
            print("Making coffee for customer 2")
        }

        queue.async {
            print("Cleaning table for customer 3")
        }
    }

    static func operationQueue() {
        // OperationQueue is like your café manager who plans and oversees all tasks.
        // Unlike the barista, the manager can prioritize tasks, manage dependencies
        // between tasks, and even cancel tasks if needed.
        //
        // When to Use?
        // - When you need more control over task execution.
        // - When tasks depend on each other.
        // - When you need to cancel tasks or set priorities.
        let operationQueue = OperationQueue()

        let takeOrder = BlockOperation {
            print("Taking order from customer 1")
        }

        let makeCoffee = BlockOperation {
            print("Making coffee for customer 2")
        }

        let cleanTable = BlockOperation {
            print("Cleaning table for customer 3")
        }

        // You can set dependencies so that tasks happen in a specific order:

        operationQueue.addOperation(takeOrder)
        operationQueue.addOperation(makeCoffee)
        operationQueue.addOperation(cleanTable)

        makeCoffee.addDependency(takeOrder)
        cleanTable.addDependency(makeCoffee)

        operationQueue.addOperations([takeOrder, makeCoffee, cleanTable], waitUntilFinished: false)
    }
}
