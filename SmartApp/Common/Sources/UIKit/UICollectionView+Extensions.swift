//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UICollectionView {
    func deinitialize() {
        dataSource = nil
        delegate = nil
    }

    func safelySelect(rowAt indexPath: IndexPath) {
        selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        delegate?.collectionView?(self, didSelectItemAt: indexPath)
    }
}
