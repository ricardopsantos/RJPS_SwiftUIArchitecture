//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    var textAnimated: String? {
        get { text }
        set { if text != newValue {
            fadeTransition(); text = newValue ?? ""
        } }
    }

    var getHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        // swiftlint:disable random_rule_2
        label.font = font
        // swiftlint:enable random_rule_2
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
}

fileprivate extension UILabel {
    func fadeTransition(_ duration: CFTimeInterval = 0.5) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
