//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
#if !os(watchOS)
import SystemConfiguration
#endif

public extension Common_PropertyWrappers {
    @propertyWrapper
    struct BundleFile<T> {
        public let name: String
        public let type: String
        public let fileManager: FileManager = .default
        public let bundle: Bundle = .main
        public let decoder: (Data) -> T

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public var wrappedValue: T {
            guard let path = bundle.path(forResource: name, ofType: type) else {
                fatalError("Resource not found: \(name).\(type)")
            }
            guard let data = fileManager.contents(atPath: path) else {
                fatalError("Can not load file at: \(path)")
            }
            return decoder(data)
        }
    }
}

public extension Common_PropertyWrappers.BundleFile {
    static func sampleUsage() {
        @Common_PropertyWrappers.BundleFile(
            name: "avatar",
            type: "jpg",
            decoder: { UIImage(data: $0)! }
        ) var avatar: UIImage
    }
}
