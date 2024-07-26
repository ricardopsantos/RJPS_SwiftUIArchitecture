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

extension TNConstrainable {
    static var defaultUILayoutPriority: UILayoutPriority { UILayoutPriority.almostRequired }

    @discardableResult
    func center(
        in view: TNConstrainable,
        offset: CGPoint = .zero,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        prepareForLayout()
        let constraints = [
            centerX(to: view, offset: offset.x, priority: priority, isActive: isActive),
            centerY(to: view, offset: offset.y, priority: priority, isActive: isActive)
        ]
        return constraints
    }

    @discardableResult
    func edges(
        to view: TNConstrainable,
        excluding excludedEdge: TNLayoutEdge = .none,
        insets: UIEdgeInsets = .zero,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        prepareForLayout()
        var constraints: [NSLayoutConstraint] = []
        if !excludedEdge.contains(.top) {
            constraints.append(top(to: view, offset: insets.top, relation: relation, priority: priority, isActive: isActive))
        }
        if !excludedEdge.contains(.left) {
            constraints.append(left(to: view, offset: insets.left, relation: relation, priority: priority, isActive: isActive))
        }
        if !excludedEdge.contains(.bottom) {
            constraints.append(bottom(to: view, offset: -insets.bottom, relation: relation, priority: priority, isActive: isActive))
        }
        if !excludedEdge.contains(.right) {
            constraints.append(right(to: view, offset: -insets.right, relation: relation, priority: priority, isActive: isActive))
        }
        return constraints
    }

    @discardableResult
    func size(
        _ size: CGSize,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        prepareForLayout()
        var constraints: [NSLayoutConstraint] = []
        constraints.append(width(size.width, relation: relation, priority: priority, isActive: isActive))
        constraints.append(height(size.height, relation: relation, priority: priority, isActive: isActive))
        return constraints
    }

    @discardableResult
    func size(
        to view: TNConstrainable,
        multiplier: CGFloat = 1,
        insets: CGSize = .zero,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        prepareForLayout()
        let constraints = [
            width(to: view, multiplier: multiplier, offset: insets.width, relation: relation, priority: priority, isActive: isActive),
            height(to: view, multiplier: multiplier, offset: insets.height, relation: relation, priority: priority, isActive: isActive)
        ]
        return constraints
    }

    @discardableResult
    func origin(
        to view: TNConstrainable,
        insets: UIEdgeInsets = .zero,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        prepareForLayout()
        let constraints = [
            left(to: view, offset: insets.left, relation: relation, priority: priority, isActive: isActive),
            top(to: view, offset: insets.top, relation: relation, priority: priority, isActive: isActive)
        ]
        return constraints
    }

    @discardableResult
    func width(
        _ width: CGFloat,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(viewId)]"
        switch relation {
        case .equal:
            return widthAnchor.constraint(equalToConstant: width)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return widthAnchor.constraint(lessThanOrEqualToConstant: width)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return widthAnchor.constraint(greaterThanOrEqualToConstant: width)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func width(
        to view: TNConstrainable,
        _ dimension: NSLayoutDimension? = nil,

        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(dimension.hashValue)]_[\(viewId)]->[\(view2Id)]"
        switch relation {
        case .equal:
            return widthAnchor.constraint(equalTo: dimension ?? view.widthAnchor, multiplier: multiplier, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return widthAnchor.constraint(lessThanOrEqualTo: dimension ?? view.widthAnchor, multiplier: multiplier, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return widthAnchor.constraint(greaterThanOrEqualTo: dimension ?? view.widthAnchor, multiplier: multiplier, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func widthToHeight(
        of view: TNConstrainable,

        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        width(to: view, view.heightAnchor, multiplier: multiplier, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func width(
        min: CGFloat? = nil,
        max: CGFloat? = nil,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        prepareForLayout()
        var constraints: [NSLayoutConstraint] = []
        let viewId = constrainableId
        let constraintId = "id__\(#function)_\(viewId)"
        if let min {
            let constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: min).with(priority)
            constraint.set(isActive, constraintId)
            constraints.append(constraint)
        }
        if let max {
            let constraint = widthAnchor.constraint(lessThanOrEqualToConstant: max).with(priority)
            constraint.set(isActive, constraintId)
            constraints.append(constraint)
        }
        return constraints
    }

    @discardableResult
    func height(
        _ height: CGFloat,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let constraintId = "id__\(#function)_\(relation)_\(viewId)"
        switch relation {
        case .equal:
            return heightAnchor.constraint(equalToConstant: height)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return heightAnchor.constraint(lessThanOrEqualToConstant: height)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return heightAnchor.constraint(greaterThanOrEqualToConstant: height)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func height(
        to view: TNConstrainable,
        _ dimension: NSLayoutDimension? = nil,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(dimension.hashValue)]_[\(viewId)]->[\(view.constrainableId)]"
        switch relation {
        case .equal:
            return heightAnchor.constraint(equalTo: dimension ?? view.heightAnchor, multiplier: multiplier, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return heightAnchor.constraint(lessThanOrEqualTo: dimension ?? view.heightAnchor, multiplier: multiplier, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return heightAnchor.constraint(greaterThanOrEqualTo: dimension ?? view.heightAnchor, multiplier: multiplier, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func heightToWidth(
        of view: TNConstrainable,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        height(to: view, view.widthAnchor, multiplier: multiplier, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func height(
        min: CGFloat? = nil,
        max: CGFloat? = nil,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        prepareForLayout()
        var constraints: [NSLayoutConstraint] = []
        let viewId = constrainableId
        let constraintId = "id__\(#function)_\(viewId)"
        if let min {
            let constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: min).with(priority)
            constraint.set(isActive, constraintId)
            constraints.append(constraint)
        }
        if let max {
            let constraint = heightAnchor.constraint(lessThanOrEqualToConstant: max).with(priority)
            constraint.set(isActive, constraintId)
            constraints.append(constraint)
        }
        return constraints
    }

    @discardableResult
    func aspectRatio(
        _ ratio: CGFloat,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        widthToHeight(of: self, multiplier: ratio, offset: 0, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func leadingToTrailing(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        return leading(to: view, view.trailingAnchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func leading(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(anchor.hashValue)]_[\(viewId)]->[\(view2Id)]"
        switch relation {
        case .equal:
            return leadingAnchor.constraint(equalTo: anchor ?? view.leadingAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return leadingAnchor.constraint(lessThanOrEqualTo: anchor ?? view.leadingAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return leadingAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.leadingAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func leftToRight(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        return left(to: view, view.rightAnchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func left(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(anchor.hashValue)]_[\(viewId)]_[\(view2Id)]"
        switch relation {
        case .equal:
            return leftAnchor.constraint(equalTo: anchor ?? view.leftAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return leftAnchor.constraint(lessThanOrEqualTo: anchor ?? view.leftAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return leftAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.leftAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func trailingToLeading(
        of view: TNConstrainable,

        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        return trailing(to: view, view.leadingAnchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func trailing(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(anchor.hashValue)]_[\(viewId)]->[\(view2Id)]"
        switch relation {
        case .equal:
            return trailingAnchor.constraint(equalTo: anchor ?? view.trailingAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return trailingAnchor.constraint(lessThanOrEqualTo: anchor ?? view.trailingAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return trailingAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.trailingAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func rightToLeft(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        return right(to: view, view.leftAnchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func right(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(anchor.hashValue)]_[\(viewId)]->[\(view2Id)]"
        switch relation {
        case .equal:
            return rightAnchor.constraint(equalTo: anchor ?? view.rightAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return rightAnchor.constraint(lessThanOrEqualTo: anchor ?? view.rightAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return rightAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.rightAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func topToBottom(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        return top(to: view, view.bottomAnchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func top(
        to view: TNConstrainable,
        _ anchor: NSLayoutYAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(anchor.hashValue)]_[\(viewId)]->[\(view2Id)]"
        switch relation {
        case .equal:
            return topAnchor.constraint(equalTo: anchor ?? view.topAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return topAnchor.constraint(lessThanOrEqualTo: anchor ?? view.topAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return topAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.topAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func bottomToTop(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        return bottom(to: view, view.topAnchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    func bottom(
        to view: TNConstrainable,
        _ anchor: NSLayoutYAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(relation)]_[\(anchor.hashValue)]_[\(viewId)]->[\(view2Id)]"
        switch relation {
        case .equal:
            return bottomAnchor.constraint(equalTo: anchor ?? view.bottomAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrLess:
            return bottomAnchor.constraint(lessThanOrEqualTo: anchor ?? view.bottomAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        case .equalOrGreater:
            return bottomAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.bottomAnchor, constant: offset)
                .with(priority)
                .set(isActive, constraintId)
        }
    }

    @discardableResult
    func centerX(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let constraint: NSLayoutConstraint = if let anchor {
            centerXAnchor.constraint(equalTo: anchor, constant: offset).with(priority)
        } else {
            NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: multiplier, constant: offset).with(priority)
        }
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(anchor.hashValue)]_[\(viewId)]->[\(view2Id)]"
        constraint.set(isActive, constraintId)
        return constraint
    }

    @discardableResult
    func centerY(
        to view: TNConstrainable,
        _ anchor: NSLayoutYAxisAnchor? = nil,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        priority: UILayoutPriority = defaultUILayoutPriority,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        prepareForLayout()
        let constraint: NSLayoutConstraint = if let anchor {
            centerYAnchor.constraint(equalTo: anchor, constant: offset).with(priority)
        } else {
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: multiplier, constant: offset).with(priority)
        }
        let viewId = constrainableId
        let view2Id = view.constrainableId
        let constraintId = "id__\(#function)_[\(anchor.hashValue)]_[\(viewId)]->[\(view2Id)]"
        constraint.set(isActive, constraintId)
        return constraint
    }
}

// swiftlint:enable all
