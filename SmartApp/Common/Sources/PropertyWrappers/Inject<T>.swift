//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
#if !os(watchOS)
import SystemConfiguration
#endif

//
// https://avdyushin.ru/posts/swift-property-wrappers/
// https://medium.com/@anuragajwani/dependency-injection-in-ios-and-swift-using-property-wrappers-f411117cfdcf
//

public extension Common_PropertyWrappers {
    class InjectContainer {
        private let lock = NSLock()
        public static let shared = PWInjectContainer()
        public var factoryDict: [String: () -> Any] = [:]
        public func register<Service>(type: Service.Type, _ factory: @escaping () -> Service) {
            lock.lock()
            defer { lock.unlock() }
            factoryDict[String(describing: type.self)] = factory
        }

        public func resolve<Service>(_ type: Service.Type) -> Service? {
            lock.lock()
            defer { lock.unlock() }
            let sDescribing = String(describing: type.self)
            let isResolved = factoryDict.keys.filter { $0 == sDescribing }.count == 1
            if !isResolved {
                Common_Logs.error("\(Self.self) - Will fail resolving [\(type)] using [\(factoryDict.keys)]")
            }
            let block = factoryDict[sDescribing]
            return block?() as? Service
        }
    }

    @propertyWrapper
    struct Inject<T> {
        var type: T
        public init() {
            self.type = PWInjectContainer.shared.resolve(T.self)!
        }

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public var wrappedValue: T {
            get { type }
            mutating set { self.type = newValue }
        }
    }

    @propertyWrapper
    struct InjectTreadSafe<T> {
        private let lock = NSLock()
        var type: T
        public init() {
            lock.lock()
            defer { lock.unlock() }
            self.type = PWInjectContainer.shared.resolve(T.self)!
        }

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public var wrappedValue: T {
            get { type }
            mutating set {
                lock.lock()
                defer { lock.unlock() }
                self.type = newValue
            }
        }
    }
}

//
// MARK: Sample Usage
//

private protocol SomeProtocol {
    func someFunc()
}

class SomeClass: SomeProtocol {
    func someFunc() {}
}

fileprivate extension Common_PropertyWrappers.InjectTreadSafe {
    static func sampleUsage() {
        PWInjectContainer.shared.register(type: SomeProtocol.self) { SomeClass() }

        @PWInject var someVar: SomeProtocol
        someVar.someFunc()
    }
}
