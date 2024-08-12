//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

// Class must be open in order to be heritaded
open class Common_BaseOperation: Operation {
    private var _executing = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }

    override public var isExecuting: Bool { _executing }
    private var _finished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }

    override public var isFinished: Bool { _finished }
    public func executing(_ executing: Bool) { _executing = executing }
    public func finish(_ finished: Bool) { _finished = finished }
}

public class Common_BaseOperationManager {
    public init(maxConcurrentOperationCount: Int = 5) {
        if operationQueue == nil {
            self.operationQueue = OperationQueue()
            operationQueue!.maxConcurrentOperationCount = maxConcurrentOperationCount
        }
    }

    private var operationQueue: OperationQueue?
    public static var shared = Common_BaseOperationManager()

    public func add(_ operation: Operation) {
        guard let operationQueue else {
            return
        }
        if operationQueue.operations.count > 10 {
            Common_Logs.warning("Too many operations: \(operationQueue.operations.count)")
        }
        operationQueue.addOperations([operation], waitUntilFinished: false)
    }
}

//
// MARK: - Sample
//

public extension Common {
    fileprivate class DownloadImageOperation: Common_BaseOperation {
        let urlString: String
        var image: UIImage!
        init(withURLString urlString: String) {
            self.urlString = urlString
        }

        override public func main() {
            guard isCancelled == false else {
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
        let url = """
        https://media.licdn.com/dms/image/C4E03AQHpQtIamtJZPA/profile-displayphoto-shrink_800_800/0/1601550428198?e=1679529600&v=beta&t=CzTS-znGCna-m_dWXwS4gwiRsX4YVrcoDrpCC4hR9XQ
        """
        let operation = DownloadImageOperation(withURLString: url)
        Common_BaseOperationManager.shared.add(operation)
        operation.completionBlock = {
            if operation.isCancelled {
                // observer.on(.next(Images.notFound.image))
            } else {
                // observer.on(.next(operation.image))
            }
            // observer.on(.completed)
        }
    }
}
