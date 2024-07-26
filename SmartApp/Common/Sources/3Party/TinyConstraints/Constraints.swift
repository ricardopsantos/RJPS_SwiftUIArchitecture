//
//    MIT License
//
//    Copyright (c) 2017 Robert-Hein Hooijmans <rh.hooijmans@gmail.com>
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.
//

// swiftlint:disable all

import UIKit

public extension Common {
    enum ConstraintRelation: Int {
        case equal = 0
        case equalOrLess = -1
        case equalOrGreater = 1
    }
}

extension Collection where Iterator.Element == NSLayoutConstraint {
    func activate() {
        if let constraints = self as? [NSLayoutConstraint] {
            NSLayoutConstraint.activate(constraints)
        }
    }

    func deActivate() {
        if let constraints = self as? [NSLayoutConstraint] {
            NSLayoutConstraint.deactivate(constraints)
        }
    }
}

extension NSLayoutConstraint {
    @objc
    func with(_ p: UILayoutPriority) -> Self {
        priority = p
        return self
    }

    @discardableResult
    func set(_ active: Bool, _ identifier: String) -> Self {
        setActive(active, identifier: identifier)
        return self
    }
}

// swiftlint:enable all
