//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    func load(url: URL, downsample: Bool = true) {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                DispatchQueue.executeInMainTread { [weak self] in
                    guard let self else {
                        return
                    }
                    if downsample,
                       let downsampleImage = UIImage.downsample(
                           imageAt: url,
                           size: bounds.size
                       ) {
                        self.image = downsampleImage
                    } else {
                        self.image = image
                    }
                }
            }
        }
    }
}
