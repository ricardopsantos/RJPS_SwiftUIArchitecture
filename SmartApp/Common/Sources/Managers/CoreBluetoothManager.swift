//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreBluetooth

public extension Common {
    class CoreBluetoothManager: NSObject {
        override public init() {
            super.init()
        }

        private lazy var cbCentralSilentManager: CBCentralManager = { CBCentralManager(delegate: self, queue: nil, options: cannotDisplayAlert) }()
        @PWThreadSafe private(set) var cbCentralManager: CBCentralManager?
        @PWThreadSafe private var onUpdateState: ((CBManagerState?, CBManagerAuthorization?, CoreBluetoothManager.BluetoothSmartState) -> Void)?
        @PWThreadSafe private static var lastCBManagerState: CBManagerState?
        @PWThreadSafe private static var lastCBManagerAuthorization: CBManagerAuthorization?
        private let canDisplayAlert = [CBCentralManagerOptionShowPowerAlertKey: true]
        private let cannotDisplayAlert = [CBCentralManagerOptionShowPowerAlertKey: false]
    }
}

//
// MARK: - Public vars
//

public extension Common.CoreBluetoothManager {
    enum BluetoothSmartState: String {
        case bluetoothOffAndAllowed
        case bluetoothOnAndAllowed
        case bluetoothDenied // BT can be off or on, we don't know
        case unknown // User didn't answer question yet

        var isAllowed: Bool {
            switch self {
            case .bluetoothOffAndAllowed,
                 .bluetoothOnAndAllowed: true
            case .bluetoothDenied,
                 .unknown: false
            }
        }
    }

    private static var bluetoothSmartState: BluetoothSmartState = .unknown
    private var state: CBManagerState { Self.lastCBManagerState ?? cbCentralSilentManager.state }
    private var authorization: CBManagerAuthorization { Self.lastCBManagerAuthorization ?? cbCentralSilentManager.authorization }

    var bluetoothState: BluetoothSmartState {
        Self.bluetoothSmartState
    }

    var stateDebug: String {
        var result = "\(Self.bluetoothSmartState)"
        switch Self.lastCBManagerState ?? cbCentralSilentManager.state {
        case .unknown: result += " | State: unknown"
        case .resetting: result += " | State: resetting"
        case .unsupported: result += " | State: unsupported"
        case .unauthorized: result += " | State: unauthorized"
        case .poweredOff: result += " | State: poweredOff"
        case .poweredOn: result += " | State: poweredOn"
        @unknown default: result += " | State: @unknown"
        }
        switch Self.lastCBManagerAuthorization ?? cbCentralSilentManager.authorization {
        case .notDetermined: result += " | Authorization: notDetermined"
        case .restricted: result += " | Authorization: restricted"
        case .denied: result += " | Authorization: denied"
        case .allowedAlways: result += " | Authorization: allowedAlways"
        @unknown default: result += " | Authorization: @unknown"
        }
        return result
    }
}

//
// MARK: - Public funcs
//

public extension Common.CoreBluetoothManager {
    func freeResources() {
        cbCentralManager = nil
        onUpdateState = nil
        Self.lastCBManagerState = nil
        Self.lastCBManagerAuthorization = nil
    }

    /// Will request access, AND show alert if access don't exists
    func requestAccess(_ onUpdateState: @escaping ((
        CBManagerState?,
        CBManagerAuthorization?,
        Common.CoreBluetoothManager.BluetoothSmartState
    ) -> Void)) {
        self.onUpdateState = onUpdateState
        cbCentralManager = CBCentralManager(delegate: self, queue: nil, options: canDisplayAlert)
    }

    /// Will request access, but WILL NOT show alert if access don't exists
    func requestSilentAccess(_ onUpdateState: @escaping ((
        CBManagerState?,
        CBManagerAuthorization?,
        Common.CoreBluetoothManager.BluetoothSmartState
    ) -> Void)) {
        self.onUpdateState = onUpdateState
        _ = cbCentralSilentManager // lazy init
        Self.lastCBManagerState = cbCentralSilentManager.state
        Self.lastCBManagerAuthorization = cbCentralSilentManager.authorization
    }

    func startFlow(canRequestPermissions: Bool, _ completion: @escaping ((
        CBManagerState?,
        CBManagerAuthorization?,
        Common.CoreBluetoothManager.BluetoothSmartState
    ) -> Void)) {
        if authorization == .allowedAlways {
            requestSilentAccess(completion)
        } else {
            if bluetoothState == .unknown || authorization == .notDetermined, canRequestPermissions {
                requestAccess(completion)
            } else if bluetoothState.isAllowed {
                requestSilentAccess(completion)
            }
        }
    }
}

//
// MARK: - CBCentralManagerDelegate
//

extension Common.CoreBluetoothManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let changed1 = Self.lastCBManagerState != central.state
        let changed2 = Self.lastCBManagerAuthorization != central.authorization
        if changed1 || changed2 {
            Self.lastCBManagerState = central.state
            Self.lastCBManagerAuthorization = central.authorization
        }

        if central.state == .poweredOn, central.authorization == .allowedAlways {
            Self.bluetoothSmartState = .bluetoothOnAndAllowed
        } else if central.state == .poweredOff, central.authorization == .allowedAlways {
            Self.bluetoothSmartState = .bluetoothOffAndAllowed
        } else if central.authorization == .denied {
            Self.bluetoothSmartState = .bluetoothDenied
        } else if central.state == .unsupported {
            // Simulator
            Self.bluetoothSmartState = .unknown
        } else {
            // We don't know if BT its ON of OFF because the user didn't accepted or responded to question
            Self.bluetoothSmartState = .unknown
        }

        onUpdateState?(central.state, central.authorization, Self.bluetoothSmartState)
    }
}
