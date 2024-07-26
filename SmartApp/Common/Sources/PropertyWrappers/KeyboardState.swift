//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

//
// https://ihor.pro/creating-keyboard-state-wrapper-in-swift-cbd5f4513f61
//

public extension Common_PropertyWrappers {
    @propertyWrapper
    final class KeyboardState: Equatable {
        public static func == (
            lhs: Common.PropertyWrappers.KeyboardState,
            rhs: Common.PropertyWrappers.KeyboardState
        ) -> Bool {
            lhs.wrappedValue == rhs.wrappedValue
        }

        public enum Mode {
            case willShow
            case didShow
        }

        private var showNotificationName: Notification.Name
        private var hideNotificationName: Notification.Name
        private var showHandler: ((Bool, CGFloat) -> Void)?

        /// The underlying value wrapped by the bindable state.
        /// The property that stores the wrapped value of the property. It is the value that is accessed when the property is read or written.
        public private(set) var wrappedValue: CGFloat = 0

        public init(_ mode: Mode) {
            self.showNotificationName = mode == .willShow ? UIResponder.keyboardWillShowNotification : UIResponder.keyboardDidShowNotification
            self.hideNotificationName = mode == .willShow ? UIResponder.keyboardWillHideNotification : UIResponder.keyboardDidHideNotification
            [showNotificationName, hideNotificationName].forEach {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyboardNotification(_:)),
                    name: $0,
                    object: nil
                )
            }
        }

        /// The projectedValue is an optional property that provides access to the wrapper's "projection" of the wrapped value.
        /// The projection is a separate value that can be used to perform additional operations on the wrapped value.
        /// It is accessed by appending a dollar sign ($) to the property name.
        public var projectedValue: (@escaping (Bool, CGFloat) -> Void) -> Void {
            { [weak self] in
                self?.showHandler = $0
            }
        }

        @objc private func keyboardNotification(_ notification: Notification) {
            let show = notification.name == showNotificationName
            wrappedValue = show ? (notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect)?.height ?? 0 : 0
            showHandler?(show, wrappedValue)
        }

        deinit {
            [showNotificationName, hideNotificationName].forEach {
                NotificationCenter.default.removeObserver(self, name: $0, object: nil)
            }
        }
    }
}

fileprivate extension Common_PropertyWrappers.KeyboardState {
    static func sampleUsage() {
        @Common_PropertyWrappers.KeyboardState(.willShow) var willKeyboardState
        @Common_PropertyWrappers.KeyboardState(.didShow) var didKeyboardState

        // $willKeyboardState { [weak self] show in {
        //
        //    }
        // }
    }
}
