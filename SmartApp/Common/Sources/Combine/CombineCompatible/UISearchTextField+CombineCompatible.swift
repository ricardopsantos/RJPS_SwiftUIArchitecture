//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import UIKit

public extension UISearchTextField {
    var textAnimated: String? {
        get { text }
        set { if text != newValue {
            fadeTransition(); text = newValue ?? ""
        } }
    }

    private func fadeTransition(_ duration: CFTimeInterval = 0.5) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}

public extension CombineCompatible {
    var editingChangedPublisher: AnyPublisher<String?, Never> {
        if let target = target as? UISearchTextField {
            target.valueChangedPublisher
        } else {
            AnyPublisher.never()
        }
    }

    var textDidChangePublisher: AnyPublisher<String?, Never> {
        if let target = target as? UISearchTextField {
            target.textDidChangePublisher
        } else {
            AnyPublisher.never()
        }
    }
}

public extension UISearchTextField {
    var textDidChangeNotificationPublisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: self)
    }

    var textDidChangePublisher: AnyPublisher<String?, Never> {
        textDidChangePublisherRegularDebounce
    }

    var textDidChangePublisherSmallDebounce: AnyPublisher<String?, Never> {
        textDidChangeNotificationPublisher
            .map { ($0.object as? UISearchTextField)?.text }
            .debounce(for: .milliseconds(Self.smallDebounce), scheduler: RunLoop.main).eraseToAnyPublisher()
    }

    var textDidChangePublisherRegularDebounce: AnyPublisher<String?, Never> {
        textDidChangeNotificationPublisher
            .map { ($0.object as? UISearchTextField)?.text }
            .debounce(for: .milliseconds(Self.regularDebounce), scheduler: RunLoop.main).eraseToAnyPublisher()
    }

    var textDidChangePublisherBigDebounce: AnyPublisher<String?, Never> {
        textDidChangeNotificationPublisher
            .map { ($0.object as? UISearchTextField)?.text }
            .debounce(for: .milliseconds(Self.bigDebounce), scheduler: RunLoop.main).eraseToAnyPublisher()
    }
}

public extension CombineCompatibleProtocol where Self: UISearchTextField {
    var valueChangedPublisher: AnyPublisher<String?, Never> { editingChangedPublisherRegularDebounce }

    var editingChangedPublisherSmallDebounce: AnyPublisher<String?, Never> {
        Common.UIControlPublisher(control: self, events: [.editingChanged]).map(\.text)
            .debounce(for: .milliseconds(Self.smallDebounce), scheduler: RunLoop.main).eraseToAnyPublisher()
            .eraseToAnyPublisher()
    }

    var editingChangedPublisherRegularDebounce: AnyPublisher<String?, Never> {
        Common.UIControlPublisher(control: self, events: [.editingChanged]).map(\.text)
            .debounce(for: .milliseconds(Self.regularDebounce), scheduler: RunLoop.main).eraseToAnyPublisher()
            .eraseToAnyPublisher()
    }

    var editingChangedPublisherBigDebounce: AnyPublisher<String?, Never> {
        Common.UIControlPublisher(control: self, events: [.editingChanged]).map(\.text)
            .debounce(for: .milliseconds(Self.bigDebounce), scheduler: RunLoop.main).eraseToAnyPublisher()
            .eraseToAnyPublisher()
    }
}

fileprivate extension UISearchTextField {
    static var smallDebounce = 250
    static var regularDebounce = smallDebounce * 2
    static var bigDebounce = smallDebounce * 2
}

fileprivate extension Common {
    func sample() {
        let search = UISearchTextField()

        _ = search.textDidChangePublisher.sinkToReceiveValue { _ in }
        _ = search.combine.editingChangedPublisher.sinkToReceiveValue { _ in }

        _ = search.textDidChangePublisher.sinkToReceiveValue { _ in }
        _ = search.combine.textDidChangePublisher.sinkToReceiveValue { _ in }

        search.sendActions(for: .editingChanged)
    }
}
