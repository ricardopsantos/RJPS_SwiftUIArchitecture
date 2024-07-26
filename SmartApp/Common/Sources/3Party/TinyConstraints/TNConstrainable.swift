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

// swiftlint:disable all

import UIKit

extension UIView: TNConstrainable {
    @discardableResult
    public func prepareForLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

extension UILayoutGuide: TNConstrainable {
    @discardableResult
    public func prepareForLayout() -> Self { self }
}

public protocol TNConstrainable {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }

    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }

    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }

    @discardableResult
    func prepareForLayout() -> Self

    var constrainableId: String { get }
}

public extension TNConstrainable {
    // https://stackoverflow.com/questions/24058906/printing-a-variable-memory-address-in-swift
    var constrainableId: String {
        if let view = self as? UIView {
            var accessibilityId = ""
            if let accessibilityIdentifier = view.accessibilityIdentifier {
                accessibilityId = ".[accessibility:\(accessibilityIdentifier)]"
            }
            let tag = view.tag > 0 ? ".[tag:\(view.tag)]" : ""
            let mainId = "[\(NSStringFromClass(type(of: self) as! AnyClass))].[\(Unmanaged.passUnretained(view).toOpaque())]"
            return "\(mainId)\(accessibilityId)\(tag)"
        } else {
            return "unknow_memory_address"
        }
    }
}

// swiftlint:enable all
