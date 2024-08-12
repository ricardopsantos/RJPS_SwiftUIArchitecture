//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension Thread {
    static var isMain: Bool {
        // return isMainThreadV2
        isMainThread
    }

    static var isMainThreadV2: Bool {
        switch Thread.current.qualityOfService {
        case .userInteractive: true
        case .userInitiated: false
        case .utility: false
        case .background: false
        case .default: false
        @unknown default: false
        }
    }

    static var info: String {
        "\r⚡️: \(Thread.current.threadName)\r" + "🏭: \(Thread.current.queueName)\r"
    }

    var threadName: String {
        if isMainThread {
            "main"
        } else if let threadName = Thread.current.name, !threadName.isEmpty {
            threadName
        } else {
            description
        }
    }

    var queueName: String {
        if let queueName = String(validatingUTF8: __dispatch_queue_get_label(nil)) {
            return queueName
        } else if let operationQueueName = OperationQueue.current?.name, !operationQueueName.isEmpty {
            return operationQueueName
        } else if let dispatchQueueName = OperationQueue.current?.underlyingQueue?.label, !dispatchQueueName.isEmpty {
            return dispatchQueueName
        } else {
            return "n/a"
        }
    }
}
