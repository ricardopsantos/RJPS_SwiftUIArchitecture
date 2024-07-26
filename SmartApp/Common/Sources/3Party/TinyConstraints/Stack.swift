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

public extension UIView {
    @discardableResult
    func stack(
        _ views: [UIView],
        axis: NSLayoutConstraint.Axis = .vertical,
        spacing: CGFloat = 0, // Space between subviews
        fill: Bool, // If true, last view try to hanchor on super view (bottom or rigth)
        margin: CGFloat? // Space between subviews and super view margin
    ) -> [NSLayoutConstraint] {
        var offset: CGFloat = 0
        var previous: UIView?
        var constraints: [NSLayoutConstraint] = []

        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            if view.superview == nil {
                addSubview(view)
            }

            switch axis {
            case .vertical:
                constraints.append(view.top(to: previous ?? self, previous?.bottomAnchor ?? topAnchor, offset: offset))
                if let margin {
                    constraints.append(view.leftToSuperview(offset: margin))
                }
                if let margin {
                    constraints.append(view.rightToSuperview(offset: -margin))
                }
                if fill, let lastView = views.last, view == lastView {
                    constraints.append(view.bottomToSuperview(offset: offset))
                }
            case .horizontal:
                constraints.append(view.left(to: previous ?? self, previous?.rightAnchor ?? leftAnchor, offset: offset))
                if let margin {
                    constraints.append(view.topToSuperview(offset: margin))
                }
                if let margin {
                    constraints.append(view.bottomToSuperview(offset: -margin))
                }
                if fill, let lastView = views.last, view == lastView {
                    constraints.append(view.rightToSuperview(offset: offset))
                }
            @unknown default:
                fatalError()
            }

            offset = spacing
            previous = view
        }

        return constraints
    }
}

// swiftlint:enable all
