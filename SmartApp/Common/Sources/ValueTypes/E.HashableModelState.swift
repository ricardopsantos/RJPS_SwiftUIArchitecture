//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

//
// https://medium.com/eggs-design/building-a-state-driven-app-in-swiftui-using-state-machines-32379ca37283
// Building a state-driven app in SwiftUI using state machines
//

public extension Common {
    enum HashableModelState<T: Hashable>: Hashable {
        public static func == (
            lhs: HashableModelState<T>,
            rhs: HashableModelState<T>
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notLoaded, .notLoaded):
                return true
            case (.loading, .loading):
                return true
            case (.loaded(let t1), .loaded(let t2)):
                return t1 == t2
            case (.error, .error):
                return true
            default:
                return false
            }
        }

        case notLoaded
        case loading
        case loaded(T)
        case error(Error)

        public var selfValue: Int {
            switch self {
            case .notLoaded: 1
            case .loading: 2
            case .loaded: 3
            case .error: 4
            }
        }

        public var value: T? {
            switch self {
            case .loaded(let t): return t
            default: return nil
            }
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(selfValue)
            switch self {
            case .loaded(let t):
                hasher.combine(t)
            default: ()
            }
        }
    }
}

fileprivate extension Common {
    func sample() {
        struct SomethingHashable: Hashable {
            public var currencyCode: String
            public func hash(into hasher: inout Hasher) {
                hasher.combine(currencyCode)
            }
        }

        var state: HashableModelState<SomethingHashable?> = .notLoaded
        LogsManager.debug(state)

        state = HashableModelState.loaded(SomethingHashable(currencyCode: "EUR"))
        LogsManager.debug(state)
    }
}
