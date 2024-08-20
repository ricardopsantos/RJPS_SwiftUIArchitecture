//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

/**

 In Swift, @propertyWrapper is a language feature that allows you to define a reusable piece of code to manage
 the access and storage of a property. It is introduced in Swift 5.1 and it simplifies the implementation of common
 property behaviors, such as lazy initialization, property observation, and validation.

 To use a property wrapper, you define a structure or class that implements the @propertyWrapper attribute.
 The wrapper structure or class must contain a wrappedValue property that will store the value of the property
 being wrapped, and it can also contain some methods or properties to customize the behavior of the wrapped property.

 https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md
 https://nshipster.com/propertywrapper/
 https://medium.com/swlh/easy-dependency-injection-with-property-wrappers-in-swift-886a93c28ed4
 https://www.avanderlee.com/swift/property-wrappers/

 __If you’re not familiar with Property Wrappers in Swift, it’s not a big deal:__
 * We created a struct;
 * Added @propertyWrapper before its declaration;
 * Every Property Wrapper has to have wrappedValue. In our case, it has a generic type T;
 */

public typealias PWKeyboardState = Common_PropertyWrappers.KeyboardState
public typealias PWThreadSafe = Common_PropertyWrappers.ThreadSafeUnfairLock
public typealias PWUserDefaults = Common_PropertyWrappers.UserDefaults
public typealias PWKeychainStorageV1 = Common_PropertyWrappers.KeychainStorageV1
public typealias PWKeychainStorageV2 = Common_PropertyWrappers.KeychainStorageV2
public typealias PWBundleFile = Common_PropertyWrappers.BundleFile
public typealias PWProjectedOnChange = Common_PropertyWrappers.ProjectedOnChange
public typealias PWProjectedOnChangeWithCodingKey = Common_PropertyWrappers.ProjectedOnChangeWithCodingKey

public typealias PWInject = Common_PropertyWrappers.InjectTreadSafe
public typealias PWInjectContainer = Common_PropertyWrappers.InjectContainer

public extension Common {
    struct PropertyWrappers {
        private init() {}
    }
}

private extension Common.PropertyWrappers {
    /**
     `wrappedValue`: This property represents the value that is actually stored by the wrapper.
     It is the value that will be returned when the property is accessed using dot notation.

     `projectedValue`: This property is used to provide additional functionality to the wrapper by returning
     a separate value that can be used to access or modify the wrapped value. It is accessed using the
     dollar sign $ followed by the property name.
     */
    @propertyWrapper
    struct MyWrapper {
        var wrappedValue: String
        var projectedValue: Int {
            wrappedValue.count
        }
    }

    struct MyStruct {
        @MyWrapper var myString: String = "Hello, world!"
    }

    static func example() {
        let myStruct = MyStruct()
        // prints "Hello, world!"
        Common_Logs.debug(myStruct.myString)

        // prints the projected value, which is 13 (the length of "Hello, world!")
        Common_Logs.debug(myStruct.$myString)
    }
}
