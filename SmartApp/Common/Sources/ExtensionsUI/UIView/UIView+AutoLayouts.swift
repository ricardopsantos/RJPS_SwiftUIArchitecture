//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    var layouts: LayoutsWrapper { LayoutsWrapper(target: self) }
}

public struct LayoutsWrapper {
    public let target: UIView
}

//
// MARK: Utils
//

public extension NSLayoutConstraint {
    @discardableResult
    func setActive(_ state: Bool, identifier: String) -> NSLayoutConstraint {
        if state == false {
            isActive = false
            return self
        }
        (firstItem as? UIView)?.layouts.removeLayoutConstraintWith(identifier: identifier)
        (secondItem as? UIView)?.layouts.removeLayoutConstraintWith(identifier: identifier)
        guard !identifier.trim.isEmpty else {
            fatalError("Empty identifier")
        }
        self.identifier = identifier
        NSLayoutConstraint.activate([self])
        return self
    }

    /// Update the constant value
    func updateConstant(
        to newValue: CGFloat,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let doWork = { [weak self] in
            self?.constant = newValue
            self?.firstItem?.superview?.layoutIfNeeded() // Layout the views to reflect the constraint changes
        }
        if animated {
            UIView.animate(
                withDuration: Common.Constants.defaultAnimationsTime,
                delay: 0.0,
                options: [.curveEaseInOut],
                animations: {
                    doWork()
                },
                completion: { _ in
                    completion?()
                }
            )
        } else {
            doWork()
            completion?()
        }
    }
}

public extension LayoutsWrapper {
    var safeAreaInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func layoutConstraintsRelatedWith(_ view: UIView) -> [NSLayoutConstraint] {
        let constrainableId = view.constrainableId
        return allLayoutConstraintsAndSuperConstraints.filter { $0.identifier?.contains(constrainableId) ?? false }
    }

    var allLayoutConstraintsV2: (
        top: NSLayoutConstraint?,
        bottom: NSLayoutConstraint?,
        leading: NSLayoutConstraint?,
        trailing: NSLayoutConstraint?,
        width: NSLayoutConstraint?,
        height: NSLayoutConstraint?
    ) {
        guard target.superview?.constrainableId != nil else {
            return (
                top: nil,
                bottom: nil,
                leading: nil,
                trailing: nil,
                width: nil,
                height: nil
            )
        }
        let constraints = allLayoutConstraintsV1
        return (
            top: constraints.filter { $0.identifier?.contains("id__top") ?? false }.first,
            bottom: constraints.filter { $0.identifier?.contains("id__bottom") ?? false }.first,
            leading: constraints.filter { $0.identifier?.contains("id__leading") ?? false }.first,
            trailing: constraints.filter { $0.identifier?.contains("id__trailing") ?? false }.first,
            width: constraints.filter { $0.identifier?.contains("id__width") ?? false }.first,
            height: constraints.filter { $0.identifier?.contains("id__height") ?? false }.first
        )
    }

    var allLayoutConstraintsV1: [NSLayoutConstraint] {
        guard let constrainableId = target.superview?.constrainableId else {
            return []
        }
        return allLayoutConstraintsAndSuperConstraints.filter { $0.identifier?.contains(constrainableId) ?? false }
    }

    var allLayoutConstraintsAndSuperConstraints: [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        var _superview = target.superview
        while let superview = _superview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? UIView, first == target {
                    constraints.append(constraint)
                }
                if let second = constraint.secondItem as? UIView, second == target {
                    constraints.append(constraint)
                }
            }
            _superview = superview.superview
        }
        constraints.append(contentsOf: target.constraints)
        return constraints
    }

    func removeConstraints() {
        allLayoutConstraintsAndSuperConstraints.forEach { constraint in
            remove(constraint: constraint)
        }
        target.translatesAutoresizingMaskIntoConstraints = true
    }

    func activate(
        constraint: NSLayoutConstraint,
        with identifier: String
    ) -> NSLayoutConstraint? {
        removeLayoutConstraintWith(identifier: identifier)
        guard !identifier.trim.isEmpty else {
            fatalError("Empty identifier")
        }
        constraint.identifier = identifier
        NSLayoutConstraint.activate([constraint])
        return constraint
    }

    fileprivate func removeLayoutConstraintWith(identifier: String) {
        if let old = allLayoutConstraintsAndSuperConstraints.filter({ $0.identifier == identifier }).first {
            remove(constraint: old)
        }
    }

    func remove(constraint: NSLayoutConstraint?) {
        guard let constraint else {
            return
        }
        target.removeConstraint(constraint)
        NSLayoutConstraint.deactivate([constraint])
    }

    // Hugging => Don't want to grow
    func setGrowResistance(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) {
        target.setContentHuggingPriority(priority, for: axis)
    }

    // Compression Resistance => Don't want to shrink
    func setCompressionResistance(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) {
        target.setContentCompressionResistancePriority(priority, for: axis)
    }
}

//
// MARK: Composed
//

public extension LayoutsWrapper {
    @discardableResult
    func stackVertical(
        _ views: [UIView],
        spacing viewsInnerSpacing: CGFloat,
        fill lastViewShouldFill: Bool,
        margin marginToSuper: CGFloat? = nil
    ) -> [NSLayoutConstraint] {
        target.stack(views, axis: .vertical, spacing: viewsInnerSpacing, fill: lastViewShouldFill, margin: marginToSuper)
    }

    @discardableResult
    func stackHorizontal(
        _ views: [UIView],
        spacing viewsInnerSpacing: CGFloat,
        fill lastViewShouldFill: Bool,
        margin marginToSuper: CGFloat? = nil
    ) -> [NSLayoutConstraint] {
        target.stack(views, axis: .horizontal, spacing: viewsInnerSpacing, fill: lastViewShouldFill, margin: marginToSuper)
    }

    /// Use when the view that contains the stack/scroll, is a (container) view inside the bigger view (from a UIViewController.view)
    @discardableResult
    func addAndSetupOnSubView(
        scrollView: UIScrollView,
        with stackViewV: UIStackView,
        leadingAndTrailingMargin: CGFloat = 0,
        topMargin: CGFloat = 0,
        bottomMargin: CGFloat = 0,
        clipsToBounds: Bool
    ) -> (
        scrollView_topToSuperview: NSLayoutConstraint,
        scrollView_bottomToSuperview: NSLayoutConstraint
    ) {
        if scrollView.superview == nil {
            target.addSubview(scrollView)
        }
        if stackViewV.superview == nil {
            scrollView.addSubview(stackViewV)
        }
        stackViewV.edgeStackViewToSuperView(insets: .zero)
        scrollView.layouts.leadingToSuperview(offset: leadingAndTrailingMargin)
        scrollView.layouts.trailingToSuperview(offset: leadingAndTrailingMargin)
        let scrollView_topToSuperview = scrollView.layouts.topToSuperview(offset: topMargin)
        let scrollView_bottomToSuperview = scrollView.layouts.bottomToSuperview(offset: bottomMargin)
        scrollView.clipsToBounds = true
        if clipsToBounds {
            stackViewV.clipsToBounds = true
        } else {
            stackViewV.clipsToBounds = false // Avoiding crops shadows of inner element
        }
        return (
            scrollView_topToSuperview,
            scrollView_bottomToSuperview
        )
    }

    /// @usingSafeArea: If __true__ will use safe area to grow
    func addAndSetup(
        scrollView: UIScrollView,
        with stackViewV: UIStackView,
        usingSafeArea: Bool,
        leadingAndTrailingMargin: CGFloat = 0,
        topAnchorView: UIView? = nil,
        topMargin: CGFloat = 0,
        bottomAnchorView: UIView? = nil,
        bottomMargin: CGFloat = 0,
        clipsToBounds: Bool
    ) {
        if scrollView.superview == nil {
            target.addSubview(scrollView)
        }
        if stackViewV.superview == nil {
            scrollView.addSubview(stackViewV)
        }
        if usingSafeArea {
            Common_Utils.assert(topAnchorView == nil, message: "Not predicted topAnchorView")
            Common_Utils.assert(bottomAnchorView == nil, message: "Not predicted bottomAnchorView")
            Common_Utils.assert(leadingAndTrailingMargin == 0, message: "Not predicted leadingAndTrailingMargin")
            stackViewV.edgeStackViewToSuperView(insets: .zero)
            scrollView.layouts.edgesToSuperview()
        } else {
            stackViewV.edgeStackViewToSuperView(insets: target.safeAreaInsets)
            scrollView.layouts.leadingToSuperview(offset: leadingAndTrailingMargin)
            scrollView.layouts.trailingToSuperview(offset: leadingAndTrailingMargin)
            if let topAnchorView {
                // Passed topAnchorView
                scrollView.layouts.topToBottom(of: topAnchorView, offset: topMargin)
            } else {
                scrollView.layouts.topToSuperview(offset: UIScreen.safeAreaTopInset + topMargin)
            }
            if let bottomAnchorView {
                // Passed bottomAnchorView
                bottomAnchorView.layouts.topToBottom(of: scrollView, offset: bottomMargin)
            } else {
                scrollView.layouts.bottomToSuperview(offset: bottomMargin)
            }
        }

        if clipsToBounds {
            scrollView.clipsToBounds = true
            stackViewV.clipsToBounds = true
        } else {
            scrollView.clipsToBounds = false // Avoiding crops shadows of inner elements
            stackViewV.clipsToBounds = false // Avoiding crops shadows of inner element
        }
    }
}

//
// MARK: TinyConstraints
//

public extension UILayoutPriority {
    static var defaultForTinyConstraints: UILayoutPriority {
        .almostRequired
        // .required
    }
}

public extension LayoutsWrapper {
    @discardableResult
    func edgesToSuperview(
        excluding excludedEdge: TNLayoutEdge = .none,
        insets: UIEdgeInsets = .zero,
        priority: UILayoutPriority = .defaultForTinyConstraints
    ) -> [NSLayoutConstraint] {
        target.edgesToSuperview(excluding: excludedEdge, insets: insets, priority: priority)
    }

    @discardableResult
    func leadingToSuperview(
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.leadingToSuperview(
            anchor,
            offset: offset,
            relation: relation,
            priority: priority,
            isActive: isActive,
            usingSafeArea: usingSafeArea
        )
    }

    @discardableResult
    func trailingToSuperview(
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.trailingToSuperview(
            anchor,
            offset: offset,
            relation: relation,
            priority: priority,
            isActive: isActive,
            usingSafeArea: usingSafeArea
        )
    }

    @discardableResult
    func horizontalToSuperview(
        insets: UIEdgeInsets = .zero,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> [NSLayoutConstraint] {
        target.horizontalToSuperview(insets: insets, relation: relation, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
    }

    @discardableResult
    func verticalToSuperview(
        insets: UIEdgeInsets = .zero,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> [NSLayoutConstraint] {
        target.verticalToSuperview(insets: insets, relation: relation, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
    }

    @discardableResult
    func centerToSuperview(
        offset: CGPoint = .zero,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> [NSLayoutConstraint] {
        target.centerInSuperview(offset: offset, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
    }

    @discardableResult
    func originToSuperview(
        insets: UIEdgeInsets = .zero,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> [NSLayoutConstraint] {
        target.originToSuperview(insets: insets, relation: relation, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
    }

    @discardableResult
    func widthToSuperview(
        _ dimension: NSLayoutDimension? = nil,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.widthToSuperview(
            dimension,
            multiplier: multiplier,
            offset: offset,
            relation: relation,
            priority: priority,
            isActive: isActive,
            usingSafeArea: usingSafeArea
        )
    }

    @discardableResult
    func heightToSuperview(
        _ dimension: NSLayoutDimension? = nil,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.heightToSuperview(
            dimension,
            multiplier: multiplier,
            offset: offset,
            relation: relation,
            priority: priority,
            isActive: isActive,
            usingSafeArea: usingSafeArea
        )
    }

    @discardableResult
    func leftToSuperview(
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.leftToSuperview(
            anchor,
            offset: offset,
            relation: relation,
            priority: priority,
            isActive: isActive,
            usingSafeArea: usingSafeArea
        )
    }

    @discardableResult
    func rightToSuperview(
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.rightToSuperview(
            anchor,
            offset: offset,
            relation: relation,
            priority: priority,
            isActive: isActive,
            usingSafeArea: usingSafeArea
        )
    }

    @discardableResult
    func topToSuperview(
        _ anchor: NSLayoutYAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.topToSuperview(anchor, offset: offset, relation: relation, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
    }

    @discardableResult
    func bottomToSuperview(
        _ anchor: NSLayoutYAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.bottomToSuperview(
            anchor,
            offset: offset,
            relation: relation,
            priority: priority,
            isActive: isActive,
            usingSafeArea: usingSafeArea
        )
    }

    @discardableResult
    func centerXToSuperview(
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.centerXToSuperview(anchor, offset: offset, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
    }

    @discardableResult
    func centerYToSuperview(
        _ anchor: NSLayoutYAxisAnchor? = nil,
        offset: CGFloat = 0,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true,
        usingSafeArea: Bool = false
    ) -> NSLayoutConstraint {
        target.centerYToSuperview(anchor, offset: offset, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
    }
}

extension LayoutsWrapper: TNConstrainable {
    public var topAnchor: NSLayoutYAxisAnchor { target.topAnchor }
    public var bottomAnchor: NSLayoutYAxisAnchor { target.topAnchor }
    public var leftAnchor: NSLayoutXAxisAnchor { target.leftAnchor }
    public var rightAnchor: NSLayoutXAxisAnchor { target.rightAnchor }
    public var leadingAnchor: NSLayoutXAxisAnchor { target.leadingAnchor }
    public var trailingAnchor: NSLayoutXAxisAnchor { target.trailingAnchor }
    public var centerXAnchor: NSLayoutXAxisAnchor { target.centerXAnchor }
    public var centerYAnchor: NSLayoutYAxisAnchor { target.centerYAnchor }
    public var widthAnchor: NSLayoutDimension { target.widthAnchor }
    public var heightAnchor: NSLayoutDimension { target.heightAnchor }

    @discardableResult
    public func prepareForLayout() -> Self { LayoutsWrapper(target: target.prepareForLayout()) }

    @discardableResult
    public func center(
        in view: TNConstrainable,
        offset: CGPoint = .zero,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        target.center(in: view, offset: offset, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func edges(
        to view: TNConstrainable,
        insets: UIEdgeInsets = .zero,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        target.edges(to: view, insets: insets, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func size(_ size: CGSize, priority: UILayoutPriority = .defaultForTinyConstraints, isActive: Bool = true) -> [NSLayoutConstraint] {
        target.size(size, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func size(
        to view: TNConstrainable,
        multiplier: CGFloat = 1,
        insets: CGSize = .zero,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        target.size(to: view, multiplier: multiplier, insets: insets, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func origin(
        to view: TNConstrainable,
        insets: UIEdgeInsets = .zero,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        target.origin(to: view, insets: insets, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func maxWidth(
        _ width: CGFloat,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.width(width, relation: .equalOrLess, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func width(
        _ width: CGFloat,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.width(width, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func width(
        to view: TNConstrainable,
        _ dimension: NSLayoutDimension? = nil,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.width(to: view, dimension, multiplier: multiplier, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func widthToHeight(
        of view: TNConstrainable,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.widthToHeight(of: view, multiplier: multiplier, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func width(
        min: CGFloat? = nil,
        max: CGFloat? = nil,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        target.width(min: min, max: max, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func height(
        _ height: CGFloat,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.height(height, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func maxHeight(
        _ height: CGFloat,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.height(height, relation: .equalOrLess, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func height(
        to view: TNConstrainable,
        _ dimension: NSLayoutDimension? = nil,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.height(to: view, dimension, multiplier: multiplier, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func heightToWidth(
        of view: TNConstrainable,
        multiplier: CGFloat = 1,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.heightToWidth(of: view, multiplier: multiplier, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func height(
        min: CGFloat? = nil,
        max: CGFloat? = nil,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        target.height(min: min, max: max, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func aspectRatio(
        _ ratio: CGFloat,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.aspectRatio(ratio, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func leadingToTrailing(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.leadingToTrailing(of: view, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func leading(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.leading(to: view, anchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func leftToRight(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.leftToRight(of: view, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func left(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.left(to: view, anchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func trailingToLeading(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.trailingToLeading(of: view, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func trailing(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.trailing(to: view, anchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func rightToLeft(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.rightToLeft(of: view, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func right(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.right(to: view, anchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func topToBottom(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.topToBottom(of: view, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func top(
        to view: TNConstrainable,
        _ anchor: NSLayoutYAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.top(to: view, anchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func bottomToTop(
        of view: TNConstrainable,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.bottomToTop(of: view, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func bottom(
        to view: TNConstrainable,
        _ anchor: NSLayoutYAxisAnchor? = nil,
        offset: CGFloat = 0,
        relation: Common.ConstraintRelation = .equal,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.bottom(to: view, anchor, offset: offset, relation: relation, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func center(
        to view: TNConstrainable,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> [NSLayoutConstraint] {
        [
            centerX(to: view, nil, offset: 0, priority: priority, isActive: isActive),
            centerY(to: view, nil, offset: 0, priority: priority, isActive: isActive)
        ]
    }

    @discardableResult
    public func centerX(
        to view: TNConstrainable,
        _ anchor: NSLayoutXAxisAnchor? = nil,
        offset: CGFloat = 0,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.centerX(to: view, anchor, offset: offset, priority: priority, isActive: isActive)
    }

    @discardableResult
    public func centerY(
        to view: TNConstrainable,
        _ anchor: NSLayoutYAxisAnchor? = nil,
        offset: CGFloat = 0,
        priority: UILayoutPriority = .defaultForTinyConstraints,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        target.centerY(to: view, anchor, offset: offset, priority: priority, isActive: isActive)
    }
}
