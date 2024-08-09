//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public extension UIStackView {
    var view: UIView { self as UIView }
}

public extension UIStackView {
    static func defaultVerticalStackView(_ defaultMargin: CGFloat = 16, _ spacing: CGFloat = 5) -> UIStackView {
        var layoutMargins: UIEdgeInsets {
            let topAndBottomSpacing: CGFloat = 0
            return UIEdgeInsets(
                top: topAndBottomSpacing,
                left: defaultMargin,
                bottom: topAndBottomSpacing,
                right: defaultMargin
            )
        }

        let some = UIStackView()
        some.isLayoutMarginsRelativeArrangement = true
        some.axis = .vertical
        some.distribution = .fill
        some.spacing = spacing
        some.alignment = .fill
        some.autoresizesSubviews = false
        some.layoutMargins = layoutMargins
        some.clipsToBounds = false // Avoiding crops shadows of inner elements
        return some
    }

    static func defaultHorizontalStackView(_ defaultMargin: CGFloat = 16, _ spacing: CGFloat = 5) -> UIStackView {
        var layoutMargins: UIEdgeInsets {
            let topAndBottomSpacing: CGFloat = 0
            return UIEdgeInsets(
                top: topAndBottomSpacing,
                left: defaultMargin,
                bottom: topAndBottomSpacing,
                right: defaultMargin
            )
        }

        let some = UIStackView()
        some.isLayoutMarginsRelativeArrangement = true
        some.axis = .horizontal
        some.spacing = spacing
        some.distribution = .equalCentering
        some.alignment = .center
        some.autoresizesSubviews = false
        some.layoutMargins = layoutMargins
        some.clipsToBounds = false // Avoiding crops shadows of inner elements
        return some
    }
}

public extension UIStackView {
    func addSeparator(color: UIColor = UIColor.darkGray, size: CGFloat = 3) {
        let separator = UIView()
        separator.backgroundColor = color
        if color == .clear {
            separator.tag = Common.AppTags.stackViewInvisibleSeparatorLine.tag
        } else {
            separator.tag = Common.AppTags.stackViewVisibleSeparatorLine.tag
        }
        addArrangedSubview(separator)
        separator.heightAnchor.constraint(equalToConstant: size).isActive = true
    }

    func edgeStackViewToSuperView(insets: UIEdgeInsets = .zero) {
        guard let superview else {
            return
        }
        layouts.edgesToSuperview(insets: insets) // Don't use RJPSLayouts. It will fail if scroll view is inside of stack view with lots of elements
        layouts.width(to: superview) // NEEDS THIS!
    }

    func addHorizontallyCentered(any: Any, margin: CGFloat) {
        if let view = any as? UIView {
            let stackViewH = UIStackView.defaultHorizontalStackView(0, 0)
            let lMargin = UIView()
            let rMargin = UIView()
            stackViewH.addArranged(uiview: lMargin)
            stackViewH.addArranged(uiview: view)
            stackViewH.addArranged(uiview: rMargin)
            addArrangedSubview(stackViewH)
            if margin > 0 {
                stackViewH.alignment = .trailing
                stackViewH.distribution = .fill
                lMargin.layouts.width(margin)
                rMargin.layouts.width(margin)
            }
            lMargin.backgroundColor = .clear
            rMargin.backgroundColor = .clear
        } else if let view = any as? AnyView {
            addHorizontallyCentered(any: view, margin: margin)
        }
    }

    func addHorizontallyCentered(any: Any, size: CGSize) {
        if let view = any as? UIView {
            let container = UIView()
            container.addSubview(view)
            view.layouts.centerToSuperview()
            view.layouts.size(size)
            container.layouts.height(size.height)
            addArrangedSubview(container)
        } else if let view = any as? AnyView {
            return addHorizontallyCentered(any: view, size: size)
        }
    }

    func addArranged(any: Any, id: String? = nil) {
        if let uiView = any as? UIView {
            addArranged(uiview: uiView, id: id)
        } else if let view = any as? AnyView {
            addArranged(view: view, id: id)
        } else {
            Common.LogsManager.error("Not predicted for [\(any)]")
        }
    }

    func addArranged(view: some View, id: String? = nil) {
        if let uiView = view.asViewController.view {
            addArranged(uiview: uiView, id: id)
        }
    }

    func addArranged(uiview: UIView?, id: String? = nil) {
        guard let uiview else { return }
        if let id {
            if uiview.superview == nil {
                addArrangedSubview(uiview)
                uiview.accessibilityIdentifier = id
                uiview.setNeedsLayout()
                uiview.layoutIfNeeded()
            } else {
                if let old = arrangedSubviews.filter({ $0.accessibilityIdentifier == id }).first {
                    arrangedSubviews.enumerated().forEach {
                        if $0.1 == uiview {
                            removeArrangedSubview(old)
                            insertArrangedSubview(uiview, at: $0.0)
                        }
                    }
                }
            }
        } else {
            if uiview.superview == nil {
                addArrangedSubview(uiview)
                uiview.setNeedsLayout()
                uiview.layoutIfNeeded()
            }
        }
    }

    func arrangedSubview(at index: Int) -> UIView? {
        guard index >= 0, index < arrangedSubviews.count else {
            return nil
        }
        return arrangedSubviews[index]
    }

    func indexOfArrangedSubview(_ view: UIView) -> Int? {
        // Iterate over arranged subviews and find the index of the provided view
        for (index, arrangedSubview) in arrangedSubviews.enumerated() {
            if arrangedSubview == view {
                return index
            }
        }
        // View not found in arrangedSubviews
        return nil
    }

    func insertArrangedSubview(_ uiview: UIView, atIndex: Int) {
        insertArrangedSubview(uiview, at: atIndex)
        setNeedsLayout()
        layoutIfNeeded()
    }

    func insertArrangedSubview(_ uiview: UIView, belowArrangedSubview subview: UIView) {
        arrangedSubviews.enumerated().forEach {
            if $0.1 == subview {
                insertArrangedSubview(uiview, at: $0.0 + 1)
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }

    func insertArrangedSubview(_ view: UIView, aboveArrangedSubview subview: UIView) {
        arrangedSubviews.enumerated().forEach {
            if $0.1 == subview {
                insertArrangedSubview(view, at: $0.0)
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }

    func removeArrangedSubview(at index: Int) {
        guard index >= 0, index < arrangedSubviews.count else {
            return // Index out of bounds
        }
        let removedView = arrangedSubviews[index]
        removeArrangedSubview(removedView)
        removedView.removeFromSuperview()
        setNeedsLayout()
        layoutIfNeeded()
    }

    func removeAllArrangedSubviews(after index: Int) {
        guard index >= 0, index < arrangedSubviews.count else {
            return
        }

        // Create a copy of the arrangedSubviews array
        let subviewsToRemove = Array(arrangedSubviews.suffix(from: index + 1))

        // Remove arranged subviews after the specified index
        for arrangedSubview in subviewsToRemove {
            NSLayoutConstraint.deactivate(arrangedSubview.constraints)
            removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
    }

    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { allSubviewsRecursive, subview -> [UIView] in
            removeArrangedSubview(subview)
            return allSubviewsRecursive + [subview]
        }
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap(\.constraints))
        // Remove the views from self
        removedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
