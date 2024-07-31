//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import CoreLocation
//
import DevTools
import Common

enum BackgroundServicesManagerInput: Hashable {
    enum AppLifeCycle: Hashable, Sendable {
        case appDidFinishLaunchingWithOptions
        case appWillTerminate
        case appWillResignActive
        case appDidEnterBackground
        case appDidBecomeActive
        case appWillEnterForeground
    }

    enum ViewLifeCycle: Hashable, Sendable {
        case viewDidAppear(appScreen: AppScreen)
        case viewDidDisappear(appScreen: AppScreen)
    }

    enum Generic: Hashable, Sendable {
        case some
    }

    case generic(_ value: Generic)
    case appLifeCycle(_ value: AppLifeCycle)
    case viewLifeCycle(_ value: ViewLifeCycle)
}

enum BackgroundServicesManagerOutput: Hashable {
    case userLocationUpdated(location: CLLocation?)
    case userLocationLost
    case internetConnectionStatusChanged(_ status: CommonNetworking.NetworkMonitorViewModel.Status)
}

enum BackgroundServicesManagerSender: Hashable {
    case enableAppBackgroundServices
    case disableAppBackgroundServices
}

/*
 Manager Observers:
 - On NetworkMonitor.start     will enableAppBackgroundServices, and emit other listeners interested
 - On NetworkMonitor.recovered will enableAppBackgroundServices, and emit other listeners interested
 - On NetworkMonitor.lost      will disableAppBackgroundServices, and emit other listeners interested
 */

class BackgroundServicesManager: NSObject {
    private static var output = PassthroughSubject<BackgroundServicesManagerOutput, Never>()
    static let shared = BackgroundServicesManager()
    fileprivate var internetConnectionIsAvailable: Bool?
    fileprivate var backgroundServicesEnabled = false {
        didSet {
            DevTools.Log.debug("\(BackgroundServicesManager.self) \(backgroundServicesEnabled ? "enabled" : "disabled")", .business)
        }
    }

    override private init() {
        super.init()
        self.enableAppBackgroundServices()
    }
}

//
// MARK: - Output utils
//

extension BackgroundServicesManager {
    typealias OutputType = BackgroundServicesManagerOutput
    public static func emit(event: OutputType) {
        Self.output.send(event)
    }

    public static func output(_ filter: [OutputType] = []) -> AnyPublisher<OutputType, Never> {
        if filter.isEmpty {
            return Self.output.eraseToAnyPublisher()
        } else {
            return Self.output.filter { filter.contains($0) }.eraseToAnyPublisher()
        }
    }
}

//
// MARK: Turn on/off all services
//

fileprivate extension BackgroundServicesManager {
    func enableAppBackgroundServices() {
        guard !backgroundServicesEnabled else {
            return
        }
        backgroundServicesEnabled = true
    }

    func disableAppBackgroundServices() {
        guard backgroundServicesEnabled else {
            return
        }
        backgroundServicesEnabled = false
    }
}

//
// MARK: - AppBackgroundServices: startObservers
//

fileprivate extension BackgroundServicesManager {
    func startObservers() {
        guard !DevTools.onRunningPreview else {
            return
        }
        Common_Utils.executeOnce(token: "\(Self.self)_\(#function)") { [weak self] in
            guard let self = self else { return }
            self.enableAppBackgroundServices()
            CommonNetworking.NetworkMonitor.shared.start { [weak self] currentStatus in
                Self.output.send(.internetConnectionStatusChanged(currentStatus))
                self?.enableAppBackgroundServices()
            } onRecovered: { [weak self] currentStatus in
                Self.output.send(.internetConnectionStatusChanged(currentStatus))
                self?.enableAppBackgroundServices()
            } onLost: { [weak self] currentStatus in
                Self.output.send(.internetConnectionStatusChanged(currentStatus))
                self?.disableAppBackgroundServices()
            }
        }
    }
}

extension BackgroundServicesManager {
    func handleEvent(_ event: BackgroundServicesManagerInput, _ some: Any?) {
        switch event {
        case .generic(let state):
            switch state {
            case .some:
                ()
            }
        case .appLifeCycle(let state):
            switch state {
            case .appDidFinishLaunchingWithOptions:
                startObservers()
            case .appWillTerminate: ()
            case .appWillResignActive: ()
            case .appDidEnterBackground:
                disableAppBackgroundServices()
            case .appDidBecomeActive: ()
            case .appWillEnterForeground: ()
            }
        case .viewLifeCycle(let state):
            switch state {
            case .viewDidAppear: ()
            case .viewDidDisappear: ()
            }
        }
    }
}
