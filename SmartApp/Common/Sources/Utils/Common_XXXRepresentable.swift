//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

//
// https://finsi-ennes.medium.com/how-to-use-live-previews-in-uikit-204f028df3a9
// https://swiftwithmajid.com/2021/03/10/mastering-swiftui-previews/
//

public extension Common {
    struct ViewControllerRepresentable: UIViewControllerRepresentable {
        let viewControllerBuilder: () -> UIViewController

        public init(_ viewControllerBuilder: @escaping () -> UIViewController) {
            self.viewControllerBuilder = viewControllerBuilder
        }

        public func makeUIViewController(context: Context) -> some UIViewController {
            let vc = viewControllerBuilder()
            // vc.modalPresentationStyle = .overCurrentContext
            return vc
        }

        public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            // Not needed
        }
    }

    struct ViewRepresentable1: UIViewRepresentable {
        let view: UIView
        public init(view: UIView) {
            self.view = view
        }

        public init(closure: () -> (UIView)) {
            self.view = closure()
        }

        public func makeUIView(context: Context) -> UIView {
            view
        }

        public func updateUIView(_ uiView: UIView, context: Context) {}
    }

    struct ViewRepresentable2: UIViewRepresentable {
        let viewBuilder: () -> UIView
        public init(_ viewBuilder: @escaping () -> UIView) {
            self.viewBuilder = viewBuilder
        }

        public func makeUIView(context: Context) -> some UIView {
            viewBuilder()
        }

        public func updateUIView(_ uiView: UIViewType, context: Context) {
            // Not needed
        }
    }
}

//
// MARK: - Preview
//

enum Commom_Previews_ViewControllerRepresentable {
    class SampleVC: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            let imageView = UIImageView()
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
                imageView.heightAnchor.constraint(equalTo: view.widthAnchor)
            ])
        }
    }

    #if canImport(SwiftUI) && DEBUG
    // ViewController Preview
    struct PreviewProvider_1: PreviewProvider {
        static var previews: some View {
            Common_ViewControllerRepresentable { SampleVC() }
        }
    }

    // View Preview
    struct PreviewProvider_2: PreviewProvider {
        static var previews: some View {
            Common_ViewRepresentable { SampleVC().view }.buildPreviews()
        }
    }
    #endif
}
