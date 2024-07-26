//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public class StateMachine<P: StateMachineDelegateProtocol> {
    private unowned let delegate: P

    private var _state: P.StateType {
        didSet {
            delegate.didTransitionFrom(from: oldValue, to: _state)
        }
    }

    public var state: P.StateType {
        get {
            _state
        }
        set {
            delegateTransitionTo(to: newValue)
        }
    }

    public init(initialState: P.StateType, delegate: P) {
        self._state = initialState // set the primitive to avoid calling the delegate.
        self.delegate = delegate
    }

    private func delegateTransitionTo(to: P.StateType) {
        switch delegate.shouldTransitionFrom(from: _state, to: to) {
        case .allowed:
            _state = to
        case .redirected(let newState):
            _state = to
            state = newState
        case .denied:
            break
        }
    }
}

public protocol StateMachineDelegateProtocol: AnyObject {
    associatedtype StateType
    func shouldTransitionFrom(from: StateType, to: StateType) -> StateMachineShould<StateType>
    func didTransitionFrom(from: StateType, to: StateType)
}

public enum StateMachineShould<T> {
    case allowed
    case denied
    case redirected(T)
}
