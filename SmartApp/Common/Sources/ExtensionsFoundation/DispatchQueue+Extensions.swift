//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

//
// https://blog.nfnlabs.in/run-tasks-on-background-thread-swift-5d3aec272140
//

public extension DispatchQueue {
    static let defaultDelay: Double = Common.Constants.defaultAnimationsTime

    enum Tread { case main
        case background
    }

    @PWThreadSafe private static var _onceTracker = [String]()
    static func onceTrackerClean() {
        Common_Logs.warning("\(DispatchQueue.self)._onceTracker FULL clean...")
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        _onceTracker = []
    }

    static func onceTrackerClean(tracker: String) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        _onceTracker = _onceTracker.filter { $0 != tracker }
    }

    func synced(_ lock: Any, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

    @discardableResult static func executeOnce(token: String, block: () -> Void, onIgnoredClosure: () -> Void = {}) -> Bool {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        guard !_onceTracker.contains(token) else {
            onIgnoredClosure()
            return false
        }
        _onceTracker.append(token)
        block()
        return true
    }

    static func executeWithDelay(tread: Tread = Tread.main, delay: Double = defaultDelay, block: @escaping () -> Void) {
        if tread == .main {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { block() }
        } else {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).asyncAfter(deadline: .now() + delay) { block() }
        }
    }

    static func executeIn(tread: Tread, block: @escaping () -> Void) {
        if tread == .main {
            executeInMainTread(block)
        } else {
            executeInBackgroundTread(block)
        }
    }

    static func executeInMainTread(_ block: @escaping () -> Void) {
        if Thread.isMain {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }

    static func executeInBackgroundTread(_ block: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            block()
        }
    }

    static func executeInUserInteractiveTread(_ block: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            block()
        }
    }
}
