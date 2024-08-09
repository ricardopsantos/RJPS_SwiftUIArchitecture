//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit

//
// NSAttributedString Unveiled
// https://medium.com/swlh/nsattributedstring-unveiled-6c8fb5dce86a
//

//
// Rendering Attributed Strings in SwiftUI
// https://medium.com/makingtuenti/rendering-attributed-strings-in-swiftui-8a49f6cf2315
//

public extension NSMutableAttributedString {
    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, range, _ in
            if let f = value as? UIFont,
               let newFontDescriptor = f.fontDescriptor.withFamily(font.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color {
                    removeAttribute(.foregroundColor, range: range)
                    addAttribute(.foregroundColor, value: color, range: range)
                }
            }
        }
        endEditing()
    }
}

public extension NSAttributedString {
    func setColor(_ color: UIColor, on substring: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        attributedString.addAttribute(.foregroundColor, value: color, range: (string as NSString).range(of: substring))
        return attributedString
    }
}
