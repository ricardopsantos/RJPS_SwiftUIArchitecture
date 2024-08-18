//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

// Common_BaseOperation is a custom Operation subclass that provides manual control over the execution state.
open class Common_BaseOperation: Operation {
    public var operationName: String
    public var operationWork: () -> Void = {}

    // Add a convenience initializer
    public init(
        name: String = #function,

        priority: Operation.QueuePriority = .normal
    ) {
        self.operationName = name
        super.init()
        queuePriority = priority
    }

    // Private property to track whether the operation is executing.
    // When this value is about to change, KVO notifications for "isExecuting" will be sent.
    private var _executing = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }

    // Override isExecuting to return the custom _executing property.
    override public var isExecuting: Bool { _executing }

    // Private property to track whether the operation is finished.
    // When this value is about to change, KVO notifications for "isFinished" will be sent.
    private var _finished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }

    // Override isFinished to return the custom _finished property.
    override public var isFinished: Bool { _finished }

    // Public method to update the executing state.
    public func executing(_ executing: Bool) { _executing = executing }

    // Public method to update the finished state.
    public func finish(_ finished: Bool) { _finished = finished }

    // Optionally, provide a method to change priority dynamically.
    public func setPriority(_ priority: Operation.QueuePriority) {
        queuePriority = priority
    }

    override open func main() {
        guard !isCancelled else {
            finish(true)
            return
        }
        executing(true)
        operationWork()
        finish(true)
    }
}

// Common_BaseOperationManager is responsible for managing a queue of operations.
public class Common_BaseOperationManager {
    public static var shared: Common_BaseOperationManager {
        .init(maxConcurrentOperationCount: 5)
    }

    private(set) var queue: OperationQueue = .init()
    private let maxConcurrentOperationCount: Int
    public init(maxConcurrentOperationCount: Int) {
        queue.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    // Method to add an operation with a specific priority.
    public func add(_ operation: Common_BaseOperation, withPriority priority: Operation.QueuePriority? = nil) {
        addMultiple([operation], withPriority: priority)
    }

    // Method to add an multiple operations with a specific priority.
    public func addMultiple(
        _ operations: [Common_BaseOperation],
        withPriority priority: Operation.QueuePriority? = nil
    ) {
        var operationsAcc: [Common_BaseOperation] = []
        operations.forEach { operation in
            if let priority = priority, operation.queuePriority != priority {
                operation.setPriority(priority)
            } else {
                operationsAcc.append(operation)
            }
        }

        // Log a warning if there are more than maxConcurrentOperationCount operations in the queue.
        if queue.operations.count > maxConcurrentOperationCount {
            Common_Logs.warning("Too many operations: \(queue.operations.count)")
        }

        // Add the operation to the queue.
        queue.addOperations(operationsAcc, waitUntilFinished: false)
    }

    // Optionally, provide a method to update an operation's priority in the queue.
    public func updateOperationPriority(
        _ operation: Common_BaseOperation,

        to newPriority: Operation.QueuePriority
    ) {
        operation.queuePriority = newPriority
    }
}

//
// MARK: - Sample
//

public extension Common {
    class DownloadImageOperation: Common_BaseOperation {
        let urlString: String
        var image: UIImage!
        init(withURLString urlString: String) {
            self.urlString = urlString
        }

        override public func main() {
            guard !isCancelled else {
                finish(true)
                return
            }
            executing(true)
            CommonNetworking.ImageUtils.imageFrom(
                urlString: urlString,
                caching: .hot,
                downsample: nil
            ) { image in
                self.image = image!
                self.executing(false)
                self.finish(true)
            }
        }
    }

    static func sampleUsage() {
        //
        // Sample 1
        //
        let url = """
        https://media.licdn.com/dms/image/C4E03AQHpQtIamtJZPA/profile-displayphoto-shrink_800_800/0/1601550428198?e=1679529600&v=beta&t=CzTS-znGCna-m_dWXwS4gwiRsX4YVrcoDrpCC4hR9XQ
        """
        let operation = DownloadImageOperation(withURLString: url)
        Common_BaseOperationManager.shared.add(operation, withPriority: .low)
        operation.completionBlock = {
            if operation.isCancelled {
                // observer.on(.next(Images.notFound.image))
            } else {
                // observer.on(.next(operation.image))
            }
            // observer.on(.completed)
        }

        //
        // Sample 2
        //

        // Create instances of the custom DownloadImageOperation.
        let operations = [url, url, url].map { DownloadImageOperation(withURLString: $0) }

        // Add the operations to the operation queue.
        operations.forEach { Common_BaseOperationManager.shared.add($0) }
    }
}
