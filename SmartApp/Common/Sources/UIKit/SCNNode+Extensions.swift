//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

public extension SCNNode {
    @discardableResult
    func animate(repeatCount: CGFloat = 1) -> Bool {
        func animate(node: SCNNode?) -> Bool {
            guard let node, !node.animationKeys.isEmpty else {
                return false
            }
            guard let animationKey = node.animationKeys.first else {
                return false
            }
            let player = node.animationPlayer(forKey: animationKey)
            player?.animation.repeatCount = repeatCount
            player?.play()
            return true
        }
        if animate(node: self) {
            return true
        }
        var parent = parent
        var animated = false
        while parent != nil, !animated {
            if parent!.animationKeys.contains("transform") {
                animated = animate(node: parent)
            }
            parent = parent!.parent
        }
        return animated
    }

    func playAllAnimations() {
        enumerateChildNodes { child, _ /* stop */ in
            for key in child.animationKeys {
                guard let animationPlayer = child.animationPlayer(forKey: key) else {
                    continue
                }
                animationPlayer.play()
            }
        }
    }

    func stopAllAnimations() {
        enumerateChildNodes { child, _ /* stop */ in
            for key in child.animationKeys {
                guard let animationPlayer = child.animationPlayer(forKey: key) else {
                    continue
                }
                animationPlayer.stop()
            }
        }
    }
}
