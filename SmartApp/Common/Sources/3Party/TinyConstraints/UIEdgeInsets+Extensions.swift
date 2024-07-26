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

public extension UIEdgeInsets {
    static func uniform(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    static func top(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: 0, bottom: 0, right: 0)
    }

    static func left(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: value, bottom: 0, right: 0)
    }

    static func bottom(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)
    }

    static func right(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: value)
    }

    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
    }

    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: 0, bottom: value, right: 0)
    }
}

func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    .init(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
}

// swiftlint:enable all
