//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    func enableVoiceOver() {
        accessibilityElementsHidden = false
    }

    func disableVoiceOver() {
        accessibilityElementsHidden = true
    }

    var voiceOver: String {
        get { accessibilityLabel ?? "" }
        set { if !newValue.isEmpty {
            accessibilityLabel = newValue
        } }
    }

    var voiceOverHint: String {
        get { accessibilityHint ?? "" }
        set { accessibilityHint = newValue }
    }

    var voiceOverIsEnabled: Bool {
        get { isAccessibilityElement }
        set { isAccessibilityElement = newValue }
    }

    func setupAccessibilityWith(voiceOver: String, voiceOverHint: String = "") {
        self.voiceOver = voiceOver
        self.voiceOverHint = voiceOverHint
        if let btn = self as? UIButton {
            btn.accessibilityTraits = .button
        }
        if let lbl = self as? UILabel {
            lbl.accessibilityTraits = .staticText
        }
    }
}

public extension UIBarButtonItem {
    var voiceOver: String {
        get { accessibilityLabel ?? "" }
        set { if !newValue.isEmpty {
            accessibilityLabel = newValue
        } }
    }

    var voiceOverHint: String {
        get { accessibilityHint ?? "" }
        set { accessibilityHint = newValue }
    }

    var voiceOverIsEnabled: Bool {
        get { isAccessibilityElement }
        set { isAccessibilityElement = newValue }
    }
}
