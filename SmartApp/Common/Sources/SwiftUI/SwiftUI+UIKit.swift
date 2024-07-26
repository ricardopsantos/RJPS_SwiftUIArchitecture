//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

public extension UIView {
    func setNeedsUpdateSize(animated: Bool = false, duration: TimeInterval = Common.Constants.defaultAnimationsTime) {
        let block = { [weak self] in
            self?.invalidateIntrinsicContentSize()
            self?.superview?.invalidateIntrinsicContentSize()
            self?.layoutIfNeeded()
            self?.superview?.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: duration) {
                block()
            }
        } else {
            block()
            Common_Utils.delay {
                block()
            }
        }
    }
}

//
// References:
// https://www.avanderlee.com/swiftui/integrating-swiftui-with-uikit/
//

public class SelfSizingHostingController<Content>: UIHostingController<Content> where Content: View {
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setNeedsUpdateSize()
    }
}

public extension View {
    /// SwiftUIView -> UIViewController
    var asViewController: UIViewController {
        // https://stackoverflow.com/questions/58399123/uihostingcontroller-should-expand-to-fit-contents
        let hostingViewController = UIHostingController(rootView: self)
        if #available(iOS 16.0, *) {
            hostingViewController.sizingOptions = [.intrinsicContentSize]
            return hostingViewController
        } else {
            // Fallback on earlier versions
            return SelfSizingHostingController(rootView: self)
        }
    }

    //// SwiftUI View -> UIView
    var uiView: UIView {
        let view = asViewController.view
        view?.backgroundColor = .clear
        return view!
    }

    func loadInside(view: UIView) {
        view.loadWithSwiftUIView(self)
    }

    func loadInside(viewController: UIViewController) {
        viewController.addChildSwiftUIView(self)
    }
}

public extension UIView {
    func loadWithSwiftUIView(_ swiftUIView: some View) {
        addSwiftUIView(swiftUIView)
    }

    func addSwiftUIView(_ swiftUIView: some View) {
        if let view = swiftUIView.asViewController.view {
            addSubview(view)
            view.edgesToSuperview()
        }
    }
}

public extension UIViewController {
    /// Add a SwiftUI `View` as a child of the input `UIView`.
    /// - Parameters:
    ///   - swiftUIView: The SwiftUI `View` to add as a child.
    ///   - view: The `UIView` instance to which the view should be added.
    private func addSwiftUIView(_ swiftUIView: some View, to view: UIView) {
        let hostingController = swiftUIView.asViewController
        if let newView = hostingController.view {
            // Add as a child of the current view controller.
            addChild(hostingController)

            // Add the SwiftUI view to the view controller view hierarchy.
            view.addSubview(newView)
            newView.layouts.edgesToSuperview()

            // Notify the hosting controller that it has been moved to the current view controller.
            hostingController.didMove(toParent: self)
        }
    }

    // Add Content inside a container
    func addChildSwiftUIView(_ swiftUIView: some View, into view: UIView) {
        addSwiftUIView(swiftUIView, to: view)
    }

    // Add Content inside the UIViewController view
    func addChildSwiftUIView(_ swiftUIView: some View) {
        addSwiftUIView(swiftUIView, to: view)
    }

    // Present Content from UIViewController
    func presentSwiftUIView(
        _ swiftUIView: some View,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let viewController = swiftUIView.asViewController
        viewController.modalPresentationStyle = modalPresentationStyle
        viewController.view.backgroundColor = .clear
        present(viewController, animated: animated, completion: completion)
    }
}
