//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UITextField {
    func addTextPadding(left: CGFloat) {
        let leftPadding = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: left,
            height: 0
        ))
        leftView = leftPadding
        leftViewMode = .always
    }

    func setPlaceholderFont(_ font: UIFont, color: UIColor?) {
        let placeholderText = placeholder ?? ""
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color ?? UIColor.secondaryLabel
        ]
        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
    }
}
