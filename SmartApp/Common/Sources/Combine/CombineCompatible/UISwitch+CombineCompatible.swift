//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import UIKit

public extension CombineCompatible {
    var onTurnedOnPublisher: AnyPublisher<Bool, Never> {
        if let target = target as? UISwitch {
            target.onTurnedOnPublisher
        } else {
            AnyPublisher.never()
        }
    }

    var onChangedPublisher: AnyPublisher<Bool, Never> {
        if let target = target as? UISwitch {
            target.onTurnedOnPublisher
        } else {
            AnyPublisher.never()
        }
    }
}

public extension CombineCompatibleProtocol where Self: UISwitch {
    var onChangedPublisher: AnyPublisher<Bool, Never> {
        Common.UIControlPublisher(control: self, events: [.allEditingEvents, .valueChanged]).map(\.isOn).eraseToAnyPublisher()
    }

    var onTurnedOnPublisher: AnyPublisher<Bool, Never> {
        Common.UIControlPublisher(control: self, events: [.allEditingEvents, .valueChanged]).map(\.isOn).eraseToAnyPublisher()
    }
}

// swiftlint:disable no_UIKitAdhocConstruction
fileprivate extension Common {
    func sample() {
        let switcher = UISwitch()
        switcher.isOn = false
        let submitButton = UIButton()
        submitButton.isEnabled = false

        _ = switcher.onTurnedOnPublisher.assign(to: \.isEnabled, on: submitButton)
        _ = switcher.combine.onTurnedOnPublisher.assign(to: \.isEnabled, on: submitButton)

        switcher.isOn = true
        switcher.sendActions(for: .valueChanged)
        LogsManager.debug(submitButton.isEnabled)
    }
}

// swiftlint:enable no_UIKitAdhocConstruction
